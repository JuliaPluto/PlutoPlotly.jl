import _ from "lodash"

// We start by putting all the variable interpolation here at the beginning
// We have to convert all typedarrays in the layout to normal arrays. See Issue #25
// We use lodash for this for compactness
export function removeTypedArray(o) {
  return _.isTypedArray(o) ? Array.from(o) :
  _.isPlainObject(o) ? _.mapValues(o, removeTypedArray) : 
  o
}

console.log(removeTypedArray([1, 2, 3]))