JobMiner::RemoveObject(playerid) {
  RemoveBuildingForPlayer(playerid, 16304, 353.507, 832.406, 21.710, 0.250);
  RemoveBuildingForPlayer(playerid, 16302, 375.445, 850.750, 23.429, 0.250);
  RemoveBuildingForPlayer(playerid, 16305, 390.570, 875.828, 24.046, 0.250);
  RemoveBuildingForPlayer(playerid, 16303, 323.773, 914.257, 15.789, 0.250); 
  return 1;
}

JobMiner::LoadMap() {
  new tmpobjid;
  tmpobjid = CreateDynamicObject(1673, 694.234558, 894.604492, -35.964309, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, 14581, "ab_mafiasuitea", "barbersmir1", 0x00000000);
  tmpobjid = CreateDynamicObject(19445, 694.737854, 899.600524, -33.790435, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
  tmpobjid = CreateDynamicObject(19445, 694.617736, 899.600524, -33.790435, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
  tmpobjid = CreateDynamicObject(19445, 694.617736, 894.259948, -33.790435, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
  tmpobjid = CreateDynamicObject(19445, 694.737854, 894.260314, -33.790435, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF000000);
  tmpobjid = CreateDynamicObject(19482, 694.498840, 899.391418, -33.762912, 0.000000, -0.000007, 179.999954, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF003366);
  SetDynamicObjectMaterialText(tmpobjid, 0, "{FFFFFF}PARKING", 130, "Ariel", 130, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(19482, 694.498840, 894.061279, -33.762912, 0.000000, -0.000007, 179.999954, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, -1, "none", "none", 0xFF003366);
  SetDynamicObjectMaterialText(tmpobjid, 0, "{ffffff}AREA", 130, "Ariel", 130, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(1673, 695.125122, 899.225219, -35.964309, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, 14581, "ab_mafiasuitea", "barbersmir1", 0x00000000);
  tmpobjid = CreateDynamicObject(7023, 823.305419, 807.777526, 4.284479, 0.000000, 0.000000, -154.499954, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 0, 1419, "break_fence3", "CJ_FRAME_Glass", 0x00000000);
  SetDynamicObjectMaterial(tmpobjid, 1, 1419, "break_fence3", "CJ_FRAME_Glass", 0x00000000);
  SetDynamicObjectMaterial(tmpobjid, 2, 1419, "break_fence3", "CJ_FRAME_Glass", 0x00000000);
  SetDynamicObjectMaterial(tmpobjid, 4, 1419, "break_fence3", "CJ_FRAME_Glass", 0x00000000);
  SetDynamicObjectMaterial(tmpobjid, 5, 7650, "vgnusedcar", "lightblue2_32", 0x00000000);
  tmpobjid = CreateDynamicObject(19482, 814.386657, 833.482421, 15.066363, 0.000000, 0.000000, 25.900014, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterialText(tmpobjid, 0, "{ffffff}CAPITOL", 130, "Engravers MT", 100, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(19482, 814.386657, 833.482421, 13.416361, 0.000000, 0.000000, 25.900014, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterialText(tmpobjid, 0, "{FFFFFF}MINING", 130, "Engravers MT", 110, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(19482, 814.386657, 833.482421, 14.766355, 0.000000, 0.000000, 25.900014, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterialText(tmpobjid, 0, "{000000}_____________________", 130, "Ariel", 110, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(7023, 382.193756, 985.562011, 27.965045, -0.000025, -0.000003, -79.099998, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterial(tmpobjid, 5, 7650, "vgnusedcar", "lightblue2_32", 0x00000000);
  tmpobjid = CreateDynamicObject(19482, 355.070770, 983.410644, 38.746929, 0.000025, 0.000002, 101.299797, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterialText(tmpobjid, 0, "{ffffff}CAPITOL", 130, "Engravers MT", 100, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(19482, 355.070770, 983.410644, 37.096927, 0.000025, 0.000002, 101.299797, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterialText(tmpobjid, 0, "{FFFFFF}MINING", 130, "Engravers MT", 110, 1, 0x00000000, 0x00000000, 1);
  tmpobjid = CreateDynamicObject(19482, 355.070770, 983.410644, 38.446922, 0.000025, 0.000002, 101.299797, -1, -1, -1, 300.00, 300.00); 
  SetDynamicObjectMaterialText(tmpobjid, 0, "{000000}_____________________", 130, "Ariel", 110, 1, 0x00000000, 0x00000000, 1);
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  tmpobjid = CreateDynamicObject(745, 627.529296, 812.414062, -44.208930, 0.000000, 0.000000, -55.599971, -1, -1, -1, 300.00, 300.00); 
  tmpobjid = CreateDynamicObject(896, 650.739624, 795.982299, -40.656085, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
  tmpobjid = CreateDynamicObject(2936, 551.009399, 768.876037, -19.194492, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
  tmpobjid = CreateDynamicObject(905, 551.770324, 768.084716, -18.853197, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
}
