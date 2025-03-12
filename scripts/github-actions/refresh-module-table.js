const { URL } = require("url");

function getTimestamp() {
  const now = new Date();
  const year = now.getFullYear();
  const month = (now.getMonth() + 1).toString().padStart(2, "0");
  const date = now.getDate().toString().padStart(2, "0");
  const hours = now.getHours();
  const minutes = now.getMinutes();
  const seconds = now.getSeconds();

  return `${year}${month}${date}${hours}${minutes}${seconds}`;
}

/**
 * @param {typeof import("fs")} fs
 * @param {string} dir
 */
function getSubdirNames(fs, dir) {
  return fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((x) => x.isDirectory())
    .map((x) => x.name);
}

function checkVersion(a, b) {
  const x = a.split(".").map((e) => parseInt(e, 10));
  const y = b.split(".").map((e) => parseInt(e, 10));

  for (const i in x) {
    y[i] = y[i] || 0;
    if (x[i] === y[i]) {
      continue;
    } else if (x[i] > y[i]) {
      return 1;
    } else {
      return -1;
    }
  }
  return y.length > x.length ? -1 : 0;
}

/**
 * @param {ReturnType<typeof import("@actions/github").getOctokit>} github
 * @param {typeof import("@actions/github").context} context
 * @param {typeof import("fs")} fs
 * @param {typeof import("path")} path
 */
async function generateModulesTable(github, context, fs, path) {
  const tableData = [["Module", "Version", "Docs"]];
  const moduleGroups = getSubdirNames(fs, "modules");

  const listTagsParameters = {
    ...context.repo,
  };

  const tagMap = new Map();

  // iterate through each page of tags and collect latest versioned tag by moduleGroup/moduleName
  // a tag is expected to be in the format moduleGroup/moduleName/major.minor.delta
  for await (const response of github.paginate.iterator(
    github.rest.repos.listTags,
    listTagsParameters
  )) {
    response.data.forEach((x) => {
      const lastSlash = x.name.lastIndexOf("/");
      const name = x.name.substring(0, lastSlash);
      const version = x.name.substring(lastSlash + 1);

      console.log(`tag: ${name} ${version}`);

      if (tagMap.has(name)) {
        if (checkVersion(version, tagMap.get(name)) == 1)
          tagMap.set(name, version);
      } else tagMap.set(name, version);
    });
  }

  console.log("Module versions");
  tagMap.forEach((v, k) => console.log(`${k}: ${v}`));

  for (const moduleGroup of moduleGroups) {
    var moduleGroupPath = path.join("modules", moduleGroup);
    var moduleNames = getSubdirNames(fs, moduleGroupPath);
    console.log(moduleGroupPath);

    for (const moduleName of moduleNames) {
      const modulePath = `${moduleGroup}/${moduleName}`;

      console.log(modulePath);

      var version = "unknown";
      if (tagMap.has(modulePath)) {
        version = tagMap.get(modulePath);
      } else console.log(`version missing for module: ${modulePath}`);

      const badgeUrl = new URL(`https://img.shields.io/badge/${version}-blue`);
      console.log(badgeUrl.href);

      const module = `\`${modulePath}\``;
      const versionBadge = `<image src="${badgeUrl.href}">`;

      const moduleRootUrl = `https://github.com/robertmc0/modules-test/tree/main/modules/${modulePath}`;
      const codeLink = `[🦾 Code](${moduleRootUrl}/main.bicep)`;
      const readmeLink = `[📃 Readme](${moduleRootUrl}/README.md)`;
      const docs = `${codeLink} ｜ ${readmeLink}`;

      tableData.push([module, versionBadge, docs]);
    }
  }

  // markdown-table is ESM only, so we cannot use require.
  const { markdownTable } = await import("markdown-table");
  return markdownTable(tableData, { align: ["l", "r", "r"] });
}

/**
 * @param {ReturnType<typeof import("@actions/github").getOctokit>} github
 * @param {typeof import("@actions/github").context} context
 * @param {string} newReadme
 */
async function createPullRequestToUpdateReadme(github, context, newReadme) {
  const branch = `feature/refresh-module-table-${getTimestamp()}`;

  // Create a new branch.
  await github.rest.git.createRef({
    ...context.repo,
    ref: `refs/heads/${branch}`,
    sha: context.sha,
  });

  // Update README.md.
  const { data: treeData } = await github.rest.git.createTree({
    ...context.repo,
    tree: [
      {
        type: "blob",
        mode: "100644",
        path: "README.md",
        content: newReadme,
      },
    ],
    base_tree: context.sha,
  });

  // Create a commit.
  const { data: commitData } = await github.rest.git.createCommit({
    ...context.repo,
    message: "Refresh module table",
    tree: treeData.sha,
    parents: [context.sha],
  });

  // Update HEAD of the new branch.
  await github.rest.git.updateRef({
    ...context.repo,
    // The ref parameter for updateRef is not the same as createRef.
    ref: `heads/${branch}`,
    sha: commitData.sha,
  });

  // Create a pull request.
  const { data: prData } = await github.rest.pulls.create({
    ...context.repo,
    title: "🤖 Refresh module table",
    head: branch,
    base: "main",
    maintainer_can_modify: true,
  });

  return prData.html_url;
}

/**
 * @typedef Params
 * @property {typeof require} require
 * @property {ReturnType<typeof import("@actions/github").getOctokit>} github
 * @property {typeof import("@actions/github").context} context
 * @property {typeof import("@actions/core")} core
 *
 * @param {Params} params
 */
async function refreshModuleTable({ require, github, context, core }) {
  const fs = require("fs");
  const path = require("path");
  const prettier = require("prettier");

  const oldReadme = fs.readFileSync("README.md", { encoding: "utf-8" });
  const oldTableMatch = oldReadme.match(
    /(?<=<!-- Begin Module Table -->).*(?=<!-- End Module Table -->)/s
  );

  if (oldTableMatch === null) {
    core.setFailed("Could not find module table markers in the README file.");
  }

  const oldTable = oldTableMatch[0].replace(/^\s+|\s+$/g, "");
  const newTable = await generateModulesTable(github, context, fs, path);

  if (oldTable === newTable) {
    core.info("The module table is update-to-date.");
    return;
  }

  if (oldTable !== newTable) {
    const newReadme = oldReadme.replace(oldTable, newTable);
    const newReadmeFormatted = prettier.format(newReadme, {
      parser: "markdown",
    });

    core.info(newTable);

    const prUrl = await createPullRequestToUpdateReadme(
      github,
      context,
      newReadmeFormatted
    );
    core.info(
      `The module table is outdated. A pull request ${prUrl} was created to update it.`
    );
  }
}

module.exports = refreshModuleTable;
