<?php

$pG1 = [15, 33, 25, 13, 15, 10, 22, 18, 32, 27, 17];
$pG2 = [23, 34, 27, 17, 18, 12, 25, 20, 35, 29, 18];
$pG3 = [31, 23, 23, 25, 23, 15, 28, 30, 38, 33, 24];
$pG4 = [35, 11, 15, 38, 30, 10, 34, 35, 40, 37, 30];


for ($i = 1; $i < 100000; $i++) {
    $conn->exec("INSERT INTO Einkauf (ID) VALUES ($i)");
    $zzahl = rand(1, 4);

    switch ($zzahl) {
        case 1:
            foreach ($pG1 as $j => $val) {
                $zzahl = rand(1, 100);
                if ($zzahl >= $val) {
                    $conn->exec("INSERT INTO Einkauf_Produkte (EinkaufID, ProduktID) VALUES ($i, $j)");
                }
            }
            break;
        case 2:
            foreach ($pG2 as $j => $val) {
                $zzahl = rand(1, 100);
                if ($zzahl >= $val) {
                    $conn->exec("INSERT INTO Einkauf_Produkte (EinkaufID, ProduktID) VALUES ($i, $j)");
                }
            }
            break;
        case 3:
            foreach ($pG3 as $j => $val) {
                $zzahl = rand(1, 100);
                if ($zzahl >= $val) {
                    $conn->exec("INSERT INTO Einkauf_Produkte (EinkaufID, ProduktID) VALUES ($i, $j)");
                }
            }
            break;
        case 4:
            foreach ($pG4 as $j => $val) {
                $zzahl = rand(1, 100);
                if ($zzahl >= $val) {
                    $conn->exec("INSERT INTO Einkauf_Produkte (EinkaufID, ProduktID) VALUES ($i, $j)");
                }
            }
            break;
    }
}

$conn = null;

fgetc(STDIN);