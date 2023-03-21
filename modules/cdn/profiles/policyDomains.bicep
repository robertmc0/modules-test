param domains Domain[]

type Domain = {
  name: string
}

var xx = [for d in domains: {
  id: az.resourceId('', d.name)
}]

output mappedDomains array = xx
