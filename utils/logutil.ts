import {BigNumber} from 'ethers';

export function getEtherStringResultObj(obj: any) {
  if (Object.prototype.hasOwnProperty.call(obj, '_isBigNumber')) {
    return obj.toString();
  }
  return Object.keys(obj)
    .filter((key) => !/^\d+$/.test(key))
    .reduce((p, u) => {
      p[u] = obj[u].toString();
      return p;
    }, {} as any);
}

export function getEtherStringResultArray(obj: any[]) {
  return obj.map(getEtherStringResultObj);
}

export function printEtherResult(result: any, name?: string) {
  if (name) {
    console.log(`------------------------ ${name}------------------------`);
  }
  console.table(getEtherStringResultObj(result));
}

export function printEtherResultArray(result: any[], name?: string) {
  if (name) {
    console.log(`-------------- ${name} --------------`);
  }
  console.table(getEtherStringResultArray(result));
}
