
module.exports =
  pascalCase: (str) -> str[0].toUpperCase() + str.slice(1)
  camelCase: (str) -> str[0].toLowerCase() + str.slice(1)
