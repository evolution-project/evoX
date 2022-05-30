// Copyright (c) 2014-2018 Zano Project
// Copyright (c) 2014-2018 Zano Project
// Copyright (c) 2014-2018 The Louisdor Project
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "genesis_acc.h"


namespace currency
{
#ifndef TESTNET
const std::string ggenesis_tx_pub_key_str = "db91a8107b049ec9d37a6130b4f344570e2def3a8482106dfbd462e2bd8affcf";
const genesis_tx_dictionary_entry ggenesis_dict[2] = {
    {3792787674364154481ULL,1},
    {4009227131413678588ULL,0}
};
#else 
  const std::string ggenesis_tx_pub_key_str    = "bf6440a6a794a8bfa1e5a4c73fa0eeb16e461dd85280d6c7a73bbd22f0f69d58";
  const crypto::public_key ggenesis_tx_pub_key = epee::string_tools::parse_tpod_from_hex_string<crypto::public_key>(ggenesis_tx_pub_key_str);
  const genesis_tx_dictionary_entry ggenesis_dict[5] = {
    { 4413532107669521528ULL, 2 },
    { 4848259848862559835ULL, 4 },
    { 4891306118630423916ULL, 1 },
    { 6536034028979999929ULL, 0 },
    { 15528122346224653564ULL, 3 }
};
#endif 
  


}



