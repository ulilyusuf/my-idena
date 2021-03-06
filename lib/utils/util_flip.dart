import 'package:my_idena/beans/rpc/dna_all.dart';

const int NB_MAX_FLIPKEYWORDPAIRS = 9;

class UtilFlip {
  int getFirstFlipKeyWordPairsNotUsed(DnaAll dnaAll) {
    for (var i = 0;
        i < dnaAll.dnaIdentityResponse.result.flipKeyWordPairs.length;
        i++) {
      if (!dnaAll.dnaIdentityResponse.result.flipKeyWordPairs
          .elementAt(i)
          .used) {
        return i;
      }
    }
    return 0;
  }

  int findNextFlipKeyWordPairsNotUsed(
      DnaAll dnaAll, int flipKeyWordPairsNotUsedNumber) {
    int start = flipKeyWordPairsNotUsedNumber;
    if (flipKeyWordPairsNotUsedNumber == NB_MAX_FLIPKEYWORDPAIRS) {
      start = 0;
    }
    for (var i = start;
        i < dnaAll.dnaIdentityResponse.result.flipKeyWordPairs.length;
        i++) {
      if (!dnaAll.dnaIdentityResponse.result.flipKeyWordPairs
          .elementAt(i)
          .used) {
        return i;
      }
    }
    return 0;
  }
}
