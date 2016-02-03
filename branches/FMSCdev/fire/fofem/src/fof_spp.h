//
// $Id$
//
/*{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}
* Name: Species Memory Table
* Desc: This is the same as the fof_spp.dat fofem Mortality Species file
*        this is just and in memory one, used if the DLL and Batch need it.
* Date:  2-4-04
* Author: Larry Gangi
*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}{*}*/

d_SMT sr_MSMT [] = {
/* ......................................................... Mort Brk............Cnpy Cov */
/* Species       Name                                         Eq   eq    regions     eq   */
{ "ABIAMA",  "Abies amabilis -- Pacific Silver Fir          ", 1,  26,-1, 2,-1,-1,  1 },
{ "ABIBAL",  "Abies balsamea -- Balsam Fir                  ", 1,  10, 1,-1, 3, 4,  2 },
{ "ABICON",  "Abies concolor -- White Fir                   ", 1,  27, 1, 2,-1,-1,  2 },
{ "ABIGRA",  "Abies grandis -- Grand Fir                    ", 1,  25, 1, 2,-1,-1,  3 },
{ "ABILAS",  "Abies lasiocarpa -- Subalpine Fir             ", 1,  20, 1, 2,-1,-1,  4 },
{ "ABIMAG",  "Abies magnifica -- Red Fir                    ", 1,  18, 1, 2,-1,-1,  5 },
{ "ABIPRO",  "Abies procera -- Noble Fir                    ", 1,  24,-1, 2,-1,-1,  7 },
{ "ABISPP",  "Abies species -- Firs                         ", 1,  30,-1,-1, 3, 4,  2 },
{ "ACEBAR",  "Acer barbatum -- Florida maple                ", 1,   8,-1,-1,-1, 4, 21 },
{ "ACELEU",  "Acer leucoderme -- Chalk maple                ", 1,   8,-1,-1,-1, 4, 21 },
{ "ACEMAC",  "Acer macrophyllum -- Bigleaf maple            ", 1,   3,-1, 2,-1,-1, 21 },
{ "ACENEG",  "Acer negundo -- Boxelder                      ", 1,  13,-1,-1, 3, 4, 21 },
{ "ACENIG",  "Acer nigrum -- Black maple                    ", 1,  14,-1,-1, 3, 4, 21 },
{ "ACEPEN",  "Acer pensylvanicum -- Striped maple           ", 1,  24,-1,-1, 3, 4, 21 },
{ "ACERUB",  "Acer rubrum -- Red maple                      ", 1,   7,-1,-1, 3, 4, 21 },
{ "ACESACI", "Acer saccharinum -- Silver maple              ", 1,  10,-1,-1, 3, 4, 21 },
{ "ACESACU", "Acer saccharum -- Sugar maple                 ", 1,  12,-1,-1, 3, 4, 21 },
{ "ACESPI",  "Acer spicatum -- Mountain maple               ", 1,  19,-1,-1, 3,-1, 21 },
{ "ACESPP",  "Acer species -- Maples                        ", 1,   8,-1,-1, 3, 4, 21 },
{ "AESGLA",  "Aesculus glabra -- Ohio buckeye               ", 1,  15,-1,-1, 3, 4, 39 },
{ "AESOCT",  "Aesculus octandra -- Yellow buckeye           ", 1,  29,-1,-1, 3, 4, 39 },
{ "AILALT",  "Ailanthus altissima -- Ailanthus              ", 1,  29,-1,-1, 3, 4, 39 },
{ "ALNRHO",  "Alnus rhombifolia -- White alder              ", 1,  35,-1, 2,-1,-1, 23 },
{ "ALNRUB",  "Alnus rubra -- Red alder                      ", 1,   5,-1, 2,-1,-1, 22 },
{ "AMEARB",  "Amelanchier arborea -- Serviceberry           ", 1,  29,-1,-1, 3, 4, 39 },
{ "ARBMEN",  "Arbutus menziesii -- Pacific madrone          ", 1,  34,-1, 2,-1,-1, 39 },
{ "BETALL",  "Betula alleghaniensis -- Yellow birch         ", 1,  10,-1,-1, 3, 4, 24 },
{ "BETLEN",  "Betula lenta -- Sweet birch                   ", 1,   9,-1,-1,-1, 4, 24 },
{ "BETNIG",  "Betula nigra -- River Birch                   ", 1,   8,-1,-1, 3, 4, 24 },
{ "BETOCC",  "Betula occidentalis -- Water birch            ", 1,  29,-1,-1, 3, 4, 24 },
{ "BETPAP",  "Betula papyrifera -- Paper birch              ", 1,   6,-1, 2, 3, 4, 24 },
{ "BETSPP",  "Betula species  -- Birches                    ", 1,  12,-1, 2, 3, 4, 24 },
{ "CELOCC",  "Celtis occidentalis -- Hackberry              ", 1,  14,-1,-1, 3, 4, 24 },
{ "CARAQU",  "Carya aquatica -- Water hickory               ", 1,  19,-1,-1, 3, 4, 39 },
{ "CARCAR",  "Carpinus caroliniana -- American hornbeam     ", 1,   9,-1,-1, 3, 4, 39 },
{ "CARCOR",  "Carya cordiformis -- Bitternut hickory        ", 1,  16,-1,-1, 3, 4, 39 },
{ "CARGLA",  "Carya glabra -- Pignut hickory                ", 1,  16,-1,-1, 3, 4, 39 },
{ "CARILL",  "Carya illinoensis -- Pecan                    ", 1,  15,-1,-1, 3, 4, 39 },
{ "CARLAC",  "Carya laciniosa -- Shellbark hickory          ", 1,  22,-1,-1, 3, 4, 39 },
{ "CAROVA",  "Carya ovata -- Shagbark hickory               ", 1,  19,-1,-1, 3, 4, 39 },
{ "CARSPP",  "Carya species -- Hickories                    ", 1,  23,-1,-1, 3, 4, 39 },
{ "CARTEX",  "Carya texana -- Black hickory                 ", 1,  19,-1,-1,-1, 4, 39 },
{ "CARTOM",  "Carya tomentosa -- Mockernut hickory          ", 1,  22,-1,-1, 3, 4, 39 },
{ "CASCHR",  "Castanopsis chrysophylla -- Golden chinkapin  ", 1,  24,-1, 2,-1,-1, 25 },
{ "CASDEN",  "Castanea dentata -- American chestnut         ", 1,  19,-1,-1, 3,-1, 39 },
{ "CATSPP",  "Catalpa species -- Catalpas                   ", 1,  16,-1,-1,-1, 4, 39 },
{ "CELLAE",  "Celtis laevigata -- Sugarberry                ", 1,  15,-1,-1, 3, 4, 39 },
{ "CERCAN",  "Cercis canadensis -- Eastern redbud           ", 1,  14,-1,-1, 3, 4, 39 },
{ "CHALAW",  "Chamaecyparis lawsoniana -- PortOrford-cedar  ", 1,  39,-1, 2,-1,-1,  9 },
{ "CHANOO",  "Chamaecyparis nootkatenis -- Alaska-cedar     ", 1,   2,-1, 2,-1,-1,  9 },
{ "CHATHY",  "Chamaecyparis thyoides -- Atlantic white-cedar", 1,   4,-1,-1, 3, 4,  9 },
{ "CORFLO",  "Cornus florida -- Flowering dogwood           ", 1,  20,-1,-1, 3, 4, 34 },
{ "CORNUT",  "Cornus nuttallii -- Pacific dogwood           ", 1,  35,-1, 2,-1,-1, 34 },
{ "CORSPP",  "Cornus species -- Dogwoods                    ", 1,  10,-1,-1, 3, 4, 34 },
{ "CRADOU",  "Crataegus douglasii -- Black hawthorn         ", 1,  17,-1,-1,-1, 4, 35 },
{ "CRASPP",  "Crataegus species -- Hawthorns                ", 1,  35,-1, 2,-1,-1, 35 },
{ "CRASPP",  "Crataegus species -- Hawthorns                ", 1,  17,-1,-1, 3, 4, 35 },
{ "DIOVIR",  "Diospyros virginiana -- Persimmon             ", 1,  20,-1,-1, 3, 4, 39 },
{ "FAGGRA",  "Fagus grandifolia -- American beech           ", 1,   4,-1,-1, 3, 4, 39 },
{ "FRAAMA",  "Fraxinus americana -- White ash               ", 1,  21,-1,-1, 3, 4, 39 },
{ "FRANIG",  "Fraxinus nigra -- Black ash                   ", 1,  14,-1,-1, 3, 4, 39 },
{ "FRAPEN",  "Fraxinus pennsylvanica -- Green ash           ", 1,  18,-1,-1, 3, 4, 39 },
{ "FRAPRO",  "Fraxinus profunda -- Pumpkin ash              ", 1,  16,-1,-1, 3, 4, 39 },
{ "FRAQUA",  "Fraxinus quadrangulata -- Blue ash            ", 1,   9,-1,-1, 3, 4, 39 },
{ "FRASPP",  "Fraxinus species -- Ashes                     ", 1,  21,-1,-1, 3, 4, 39 },
{ "GLETRI",  "Gleditsia triacanthos -- Honeylocust          ", 1,  17,-1,-1, 3, 4, 39 },
{ "GORLAS",  "Gordonia lasianthus -- Loblolly-bay           ", 1,  17,-1,-1,-1, 4, 39 },
{ "GYMDIO",  "Gymnocladus dioicus -- Kentucky coffeetree    ", 1,  10,-1,-1, 3, 4, 39 },
{ "HALSPP",  "Halesia species -- Silverbells                ", 1,  17,-1,-1,-1, 4, 39 },
{ "ILEOPA",  "Ilex opaca -- American holly                  ", 1,  21,-1,-1, 3, 4, 39 },
{ "JUGCIN",  "Juglans cinerea -- Butternut                  ", 1,  20,-1,-1, 3, 4, 39 },
{ "JUGNIG",  "Juglans nigra -- Black walnut                 ", 1,  20,-1,-1, 3, 4, 39 },
{ "JUNOCC",  "Juniperus occidentalis -- Western juniper     ", 1,   4,-1, 2,-1,-1, 29 },
{ "JUNSPP",  "Juniperus species -- Junipers/Redcedars       ", 1,  12,-1,-1, 3, 4, 29 },
{ "JUNVIR",  "Juniperus virginiana -- Eastern redcedar      ", 1,  17,-1,-1, 3, 4, 18 },
{ "LARLAR",  "Larix laricina -- Tamarack                    ", 1,  10,-1,-1, 3, 4, 14 },
{ "LARLYA",  "Larix lyallii -- Subalpine Larch              ", 1,  29,-1, 2,-1,-1, 30 },
{ "LAROCC",  "Larix occidentalis -- Western Larch           ", 1,  36, 1, 2,-1,-1, 14 },
{ "LIBDEC",  "Libocedrus decurrens -- Incense-cedar         ", 1,  34,-1, 2,-1,-1, 18 },
{ "LIQSTY",  "Liquidambar styraciflua -- sweetgum           ", 1,  15,-1,-1, 3, 4, 39 },
{ "LIRTUL",  "Liriodendron tulipifera -- Yellow-poplar      ", 1,  20,-1,-1, 3, 4, 39 },
{ "LITDEN",  "Lithocarpus densiflorus -- Tanoak             ", 1,  30,-1, 2,-1,-1, 39 },
{ "MACPOM",  "Maclura pomifera -- Osage-orange              ", 1,  16,-1,-1,-1, 4, 39 },
{ "MAGACU",  "Magnolia acuminata -- Cucumbertree            ", 1,  15,-1,-1, 3, 4, 39 },
{ "MAGGRA",  "Magnolia grandiflora -- Southern magnolia     ", 1,  12,-1,-1,-1, 4, 39 },
{ "MAGMAC",  "Magnolia macrophylla -- Bigleaf magnolia      ", 1,  12,-1,-1,-1, 4, 39 },
{ "MAGSPP",  "Magnolia species -- Magnolias                 ", 1,  18,-1,-1, 3, 4, 39 },
{ "MAGVIR",  "Magnolia virginiana -- Sweetbay               ", 1,  19,-1,-1, 3, 4, 39 },
{ "MALPRU",  "Malus/Prunus species -- Apples/Cherries       ", 1,  17,-1,-1,-1, 4, 39 },
{ "MALSPP",  "Malus species -- Apples                       ", 1,  22,-1,-1, 3, 4, 39 },
{ "MORALB",  "Morus alba -- White mulberry                  ", 1,  17,-1,-1,-1, 4, 39 },
{ "MORRUB",  "Morus rubra -- Red mulberry                   ", 1,  17,-1,-1,-1, 4, 39 },
{ "MORSPP",  "Morus species -- Mulberries                   ", 1,  12,-1,-1, 3, 4, 39 },
{ "NYSAQU",  "Nyssa aquatica -- Water tupelo                ", 1,   9,-1,-1,-1, 4, 39 },
{ "NYSOGE",  "Nyssa ogache -- Ogeechee tupelo               ", 1,  17,-1,-1,-1, 4, 39 },
{ "NYSSPP",  "Nyssa species -- Tupelos                      ", 1,   4,-1,-1, 3, 4, 39 },
{ "NYSSYL",  "Nyssa sylvatica -- Black tupelo               ", 1,  18,-1,-1, 3, 4, 39 },
{ "NYSSYLB", "Nyssa sylvatica var. biflora -- Swamp tupelo  ", 1,  16,-1,-1,-1, 4, 39 },
{ "OSTVIR",  "Ostrya virginiana -- Eastern hophornbeam      ", 1,  16,-1,-1, 3, 4, 39 },
{ "OXYARB",  "Oxydendrum arboreum -- Sourwood               ", 1,  15,-1,-1, 3, 4, 39 },
{ "PAUTOM",  "Paulownia tomentosa -- Paulownia              ", 1,  29,-1,-1, 3, 4, 39 },
{ "PERBOR",  "Persea borbonia -- Redbay                     ", 1,  17,-1,-1,-1, 4, 39 },
{ "PICABI",  "Picea abies -- Norway spruce                  ", 1,   8,-1,-1, 3, 4, 10 },
{ "PICENG",  "Picea engelmannii -- Engelmann spruce         ", 3,  15, 1, 2,-1,-1, 10 },
{ "PICGLA",  "Picea glauca -- White spruce                  ", 3,   4, 1, 2, 3,-1, 10 },
{ "PICMAR",  "Picea mariana -- Black spruce                 ", 3,  11,-1, 2, 3, 4, 10 },
{ "PICPUN",  "Picea pungens -- Blue spruce                  ", 3,  10, 1,-1,-1,-1, 10 },
{ "PICRUB",  "Picea rubens -- Red spruce                    ", 3,  13,-1,-1, 3, 4, 10 },
{ "PICSIT",  "Picea sitchensis -- Sitka spruce              ", 3,   6,-1, 2,-1,-1, 10 },
{ "PICSPP",  "Picea species -- Spruces                      ", 3,  13,-1,-1, 3, 4, 10 },
{ "PINALB",  "Pinus albicaulis -- Whitebark pine            ", 1,   9, 1, 2,-1,-1, 31 },
{ "PINATT",  "Pinus attenuata -- Knobcone pine              ", 1,   9,-1, 2,-1,-1, 32 },
{ "PINBAN",  "Pinus banksiana -- Jack pine                  ", 1,  19,-1,-1, 3,-1, 11 },
{ "PINCLA",  "Pinus clausa -- Sand pine                     ", 1,  14,-1,-1,-1, 4, 11 },
{ "PINCON",  "Pinus contorta -- Lodgepole pine              ", 1,   7, 1, 2,-1,-1, 11 },
{ "PINECH",  "Pinus echinata -- Shortleaf pine              ", 1,  16,-1,-1, 3, 4, 15 },
{ "PINELL",  "Pinus elliottii -- Slash pine                 ", 1,  31,-1,-1,-1, 4, 15 },
{ "PINFLE",  "Pinus flexilis -- Limber pine                 ", 1,   9, 1,-1,-1,-1, 31 },
{ "PINGLA",  "Pinus glabra -- Spruce pine                   ", 1,  14,-1,-1,-1, 4, 11 },
{ "PINJEF",  "Pinus jeffreyi -- Jeffrey pine                ", 1,  37, 1, 2,-1,-1, 12 },
{ "PINLAM",  "Pinus lambertiana -- Sugar pine               ", 1,  38, 1, 2,-1,-1, 13 },
{ "PINMON",  "Pinus monticola -- Western white pine         ", 1,  14, 1, 2,-1,-1, 14 },
{ "PINPAL",  "Pinus palustrus -- Longleaf pine              ", 1,  28,-1,-1,-1, 4, 15 },
{ "PINPON",  "Pinus ponderosa -- Ponderosa pine             ", 1,  36, 1, 2,-1,-1, 15 },
{ "PINPUN",  "Pinus pungens -- Table mountain pine          ", 1,  19,-1,-1, 3, 4, 11 },
{ "PINRES",  "Pinus resinosa -- Red pine                    ", 1,  22,-1,-1, 3, 4, 11 },
{ "PINRIG",  "Pinus rigida -- Pitch pine                    ", 1,  24,-1,-1, 3, 4, 11 },
{ "PINSAB",  "Pinus sabiniana -- Digger pine                ", 1,  12,-1, 2,-1,-1, 15 },
{ "PINSER",  "Pinus serotina -- Pond pine                   ", 1,  35,-1,-1, 3, 4, 11 },
{ "PINSPP",  "Pinus species -- Pines                        ", 1,   9,-1,-1, 3, 4, 11 },
{ "PINSTR",  "Pinus strobus -- Eastern white pine           ", 1,  24,-1,-1, 3, 4, 14 },
{ "PINSYL",  "Pinus sylvestris -- Scotch pine               ", 1,   9,-1,-1, 3, 4, 11 },
{ "PINTAE",  "Pinus taeda -- Loblolly pine                  ", 1,  30,-1,-1, 3, 4, 15 },
{ "PINVIR",  "Pinus virginiana -- Virginia pine             ", 1,  12,-1,-1, 3, 4, 11 },
{ "PLAOCC",  "Plantus occidentalis -- American sycamore     ", 1,  12,-1,-1, 3, 4, 39 },
{ "POPBAL",  "Populus balsamifera -- Balsam poplar          ", 1,  19,-1,-1, 3, 4, 27 },
{ "POPDEL",  "Populus deltoides -- Eastern cottonwood       ", 1,  19,-1,-1, 3, 4, 27 },
{ "POPGRA",  "Populus grandidentata -- Bigtooth aspen       ", 1,  18,-1,-1, 3, 4, 26 },
{ "POPHET",  "Populus heterophylla -- Swamp cottonwood      ", 1,  29,-1,-1, 3, 4, 27 },
{ "POPSPP",  "Populus species -- Poplars                    ", 1,  17,-1,-1, 3, 4, 27 },
{ "POPTRE",  "Populus tremuloides -- Quaking aspen          ", 4,  23, 1, 2, 3, 4, 26 },
{ "POPTRI",  "Populus trichocarpa -- Black cottonwood       ", 1,  23,-1, 2,-1,-1, 27 },
{ "PRUAME",  "Prunus americana -- American plum             ", 1,  19,-1,-1, 3,-1, 39 },
{ "PRUEMA",  "Prunus emarginata -- Bitter cherry            ", 1,  35,-1, 2,-1,-1, 36 },
{ "PRUDEN",  "Prunus pensylvanica -- Pin cherry             ", 1,  24,-1,-1, 3, 4, 36 },
{ "PRUSER",  "Prunus serotina -- Black cherry               ", 1,   9,-1,-1, 3, 4, 36 },
{ "PRUSPP",  "Prunus species -- Cherries                    ", 1,  29,-1,-1, 3, 4, 36 },
{ "PRUVIR",  "Prunus virginiana -- Chokecherry              ", 1,  19,-1,-1, 3,-1, 36 },
{ "PSEMEN",  "Pseudotsuga menziesii -- Douglas-fir          ", 1,  36, 1, 2,-1,-1, 16 },
{ "QUEAGR",  "Quercus agrifolia -- Coast live oak           ", 1,  29,-1, 2,-1,-1, 28 },
{ "QUEALB",  "Quercus alba -- White oak                     ", 1,  19,-1,-1, 3, 4, 28 },
{ "QUEBIC",  "Quercus bicolor -- Swamp white oak            ", 1,  24,-1,-1, 3, 4, 28 },
{ "QUECHR",  "Quercus chrysolepis -- Canyon live oak        ", 1,   3,-1, 2,-1,-1, 28 },
{ "QUEOCC",  "Quercus coccinea -- Scarlet oak               ", 1,  19,-1,-1, 3, 4, 28 },
{ "QUEDOU",  "Quercus douglasii -- Blue oak                 ", 1,  12,-1, 2,-1,-1, 28 },
{ "QUEELL",  "Quercus ellipsoidalis -- Northern pin oak     ", 1,  17,-1,-1, 3, 4, 28 },
{ "QUEENG",  "Quercus engelmannii -- Engelmann oak          ", 1,  33,-1, 2,-1,-1, 28 },
{ "QUEFAL",  "Quercus falcata -- Southern red oak           ", 1,  23,-1,-1, 3, 4, 28 },
{ "QUEGAR",  "Quercus garryana -- Oregon white oak          ", 1,   8,-1, 2,-1,-1, 28 },
{ "QUEIMB",  "Quercus imbricaria -- Shingle oak             ", 1,  20,-1,-1, 3, 4, 28 },
{ "QUEINC",  "Quercus incana -- Bluejack oak                ", 1,  17,-1,-1,-1, 4, 28 },
{ "QUEKEL",  "Quercus kellogii -- Califonia black oak       ", 1,   9,-1, 2,-1,-1, 28 },
{ "QUELAE",  "Quercus laevis -- Turkey oak                  ", 1,  16,-1,-1,-1, 4, 28 },
{ "QUELAU",  "Quercus laurifolia -- Laurel oak              ", 1,  15,-1,-1,-1, 4, 28 },
{ "QUELOB",  "Quercus lobata -- California white oak        ", 1,  22,-1, 2,-1,-1, 28 },
{ "QUELYR",  "Quercus lyrata -- Overcup oak                 ", 1,  18,-1,-1, 3, 4, 28 },
{ "QUEMAC",  "Quercus macrocarpa -- Bur oak                 ", 1,  21,-1,-1, 3, 4, 28 },
{ "QUEMAR",  "Quercus marilandica -- Blackjack oak          ", 1,  16,-1,-1, 3, 4, 28 },
{ "QUEMIC",  "Quercus michauxii -- Swamp chestnut oak       ", 1,  25,-1,-1, 3, 4, 28 },
{ "QUEMUE",  "Quercus muehlenbergii -- Chinkapin oak        ", 1,  21,-1,-1, 3, 4, 28 },
{ "QUENIG",  "Quercus nigra -- Water oak                    ", 1,  15,-1,-1, 3, 4, 28 },
{ "QUENUT",  "Quercus nuttallii -- Nuttall oak              ", 1,   9,-1,-1,-1, 4, 28 },
{ "QUEPAL",  "Quercus palustris -- Pin oak                  ", 1,  20,-1,-1, 3, 4, 28 },
{ "QUEPHE",  "Quercus phellos -- Willow oak                 ", 1,  20,-1,-1, 3, 4, 28 },
{ "QUEPRI",  "Quercus prinus -- Chestnut oak                ", 1,  28,-1,-1, 3, 4, 28 },
{ "QUERUB",  "Quercus rubra -- Northern red oak             ", 1,  21,-1,-1, 3, 4, 28 },
{ "QUESHU",  "Quercus shumardii -- Shumard oak              ", 1,  16,-1,-1, 3, 4, 28 },
{ "QUESPP",  "Quercus species -- Oaks                       ", 1,  24,-1,-1, 3, 4, 28 },
{ "QUESTE",  "Quercus stellata -- Post oak                  ", 1,  23,-1,-1, 3, 4, 28 },
{ "QUEVEL",  "Quercus velutina -- Black oak                 ", 1,  24,-1,-1, 3, 4, 28 },
{ "QUEVIR",  "Quercus virginiana -- Live oak                ", 1,  22,-1,-1,-1, 4, 28 },
{ "QUEWIS",  "Quercus wislizenii -- Interior live oak       ", 1,  13,-1, 2,-1,-1, 28 },
{ "ROBPSE",  "Robinia pseudoacacia -- Black locust          ", 1,  28,-1,-1, 3, 4, 39 },
{ "SALDIA",  "Salix bebbiana -- Diamond willow              ", 1,  19,-1,-1, 3,-1, 37 },
{ "SALNIG",  "Salix nigra -- Black willow                   ", 1,  19,-1,-1, 3, 4, 37 },
{ "SALSPP",  "Salix species -- Willows                      ", 1,  20,-1, 2, 3, 4, 37 },
{ "SASALB",  "Sassafras albidum -- Sassafras                ", 1,  14,-1,-1, 3, 4, 39 },
{ "SEQGIG",  "Sequoia gigantea -- Giant sequoia             ", 1,  39,-1, 2,-1,-1, 17 },
{ "SEQSEM",  "Sequoia sempervirens -- Redwood               ", 1,  39,-1, 2,-1,-1, 17 },
{ "SORAME",  "Sorbus americana -- American mountain-ash     ", 1,  19,-1,-1, 3,-1, 39 },
{ "TAXBRE",  "Taxus brevifolia -- Pacific yew               ", 1,   4, 1, 2,-1,-1, 33 },
{ "TAXDIS",  "Taxodium distichum -- Baldcypress             ", 1,   4,-1,-1, 3, 4, 39 },
{ "TAXDISN", "Taxodium distictum var. nutans -- Pondcypress ", 1,  21,-1,-1,-1, 4, 39 },
{ "THUOCC",  "Thuja occidentalis -- Northern white-cedar    ", 1,   4,-1,-1, 3, 4, 18 },
{ "THUPLI",  "Thuja plicata -- Western redcedar             ", 1,  14, 1, 2,-1,-1, 18 },
{ "THUSPP",  "Thuju species -- Arborvitae                   ", 1,  12,-1,-1, 3, 4, 18 },
{ "TILAME",  "Tilia americana -- American basswod           ", 1,  17,-1,-1, 3, 4, 39 },
{ "TILHET",  "Tilia heterophylla -- White basswood          ", 1,  29,-1,-1, 3, 4, 39 },
{ "TSUCAN",  "Tsuga canadensis -- Eastern hemlock           ", 1,  18,-1,-1, 3, 4, 19 },
{ "TSUHET",  "Tsuga heterophylla -- Western hemlock         ", 1,  19, 1, 2,-1,-1, 19 },
{ "TSUMER",  "Tsuga mertensiana -- Mountain hemlock         ", 1,  19, 1, 2,-1,-1, 20 },
{ "ULMALA",  "Ulmus alata -- Winged elm                     ", 1,  10,-1,-1, 3, 4, 39 },
{ "ULMAME",  "Ulmus americana -- American elm               ", 1,  10,-1,-1, 3, 4, 39 },
{ "ULMPUM",  "Ulmus pumila -- Siberian elm                  ", 1,  17,-1,-1, 3, 4, 39 },
{ "ULMRUB",  "Ulmus rubra -- Slippery elm                   ", 1,  11,-1,-1, 3, 4, 39 },
{ "ULMSPP",  "Ulmus species -- Elms                         ", 1,  18,-1,-1, 3, 4, 39 },
{ "ULMTHO",  "Ulmus thomasii -- Rock elm                    ", 1,  12,-1,-1, 3, 4, 39 },
{ "UMBCAL",  "Umbellularia califonica -- California-laurel  ", 1,   5,-1, 2,-1,-1, 39 },
{ "",        "",                                               1,   1,-1,-1,-1,-1, 39 }};
