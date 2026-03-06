#!/usr/bin/perl -w

# Script baseado no trabalho de Alberto Garcia: http://por2gal.elpiso.org/
# Modificações feitas por Pablo Gamallo
# Para usar este script desde um shell, deves respeitar a seguinte sintaxe:
# cat  input-file  | port2gal.perl  >  output-file
##versão UTF-8
## -- Otimizado para performance --

use strict;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';
use utf8;

#print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
#print " TRANSLITERAÇÃO AUTOMÁTICA AO GALEGO DO ILG-RAG (excusas pelos erros)  \n";
#print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
#print "\n";
#print "\n";

my $vogal =  "AEIOUaeiou";
my $consAll = "bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMpPjJxXsShHqQgGñÑ";

my $vogalacentuada =  "\[áàéíóúÁÀÉÍÓÚâêîôûüãÃõÕ\]";
my $symbol = "\[\?\!\¿\¡\%\&\/\(\)\+\*\"\=\.\,\;\:\]";
my $WChar = "(\[a-zA-ZñÑáàéíóúÁÀÉÍÓÚçÇâêîôûüãÃõÕ\])";
my $NaoChar = "(\[ \?\!\¿\¡\%\&\/\(\)\+\*\"\'\=\.\,\;\:\])";
my $cons =  "(\[bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMpPjJxXsShHñÑ\])";
##faltam q e g
my $crecente =  "(ia|ie|io|ue|ua|uo|gua|guo)";
my $decrecente = "(iu|eu|ei|oi|ou|ai|au)";
my $w = "a-zA-ZñÑáàéíóúÁÀÉÍÓÚçÇâêîôûüãÃõÕäÄëËïÏöÖüÜ";

my $GR = "|cr|br|pr|tr|dr|fr|cl|bl|fl";

# OPTIMIZATION: Convert the delimited strings to hashes for O(1) lookups
my $pronCompostoStr = "|no-lo|no-los|no-la|no-las|vo-lo|vo-los|vo-la|vo-las|se-me|se-te|se-che|se-lle|se-lles|se-nos|se-vos";
my $pronStr = "|me|te|mos|mas|mo|ma|tos|tas|to|ta|che|cho|cha|chas|chos|lo|los|o|os|la|las|a|as|lle|lles|llo|lla|llos|llas|llelo|llela|se|no|vo|nos|vos|nolo|nolos|nola|nolas|volo|volos|vola|volas|seme|sete|seche|selle|selles|senos|sevos";

my %pronComposto = map { $_ => 1 } grep { length } split(/\|/, $pronCompostoStr);
my %pron         = map { $_ => 1 } grep { length } split(/\|/, $pronStr);

# OPTIMIZATION: Hashes for fast accent replacement
my %add_accent = (
    'a'=>'á', 'e'=>'é', 'i'=>'í', 'o'=>'ó', 'u'=>'ú',
    'A'=>'Á', 'E'=>'É', 'I'=>'Í', 'O'=>'Ó', 'U'=>'Ú'
);
my %strip_accent = (
    'á'=>'a', 'é'=>'e', 'í'=>'i', 'ó'=>'o', 'ú'=>'u',
    'Á'=>'A', 'É'=>'E', 'Í'=>'I', 'Ó'=>'O', 'Ú'=>'U'
);

my @l = qw(
água(s?) auga
Água(s?) Auga
([eE])uropeu(s?) uropeo
((?:[dD]es)?)([nN])ível ivel
((?:[dD]es)?)([nN])íveis iveis
(f)acto(s?) eito
(a)tor(e?s?) ctor
(a)tri(z)(e?s?) ctri
([sS])im i
([aA])té ta
([aA])li lí
([aA])i í
([aA])dvogad- vogad
[aA]çúcar zucre
([aA])ssassínio(s?) sasinato
([aA])ssassi- sasi
([aA]nali)s- z
([bB]isa|[aA])vô(s?) bó
([bB]isa|[aA])vó(s?) boa
([aA]ce)it- pt
Adiciona(r|[aáãeéeíoóuú])- Engadi
adiciona(r|[aáãeéeíoóuú])- engadi
Adicion(a|[ms]) Engade
adiciona(a|[ms]) engade
Apresent- Present
apresent- present
([aA])rrast([aáãeéeíoóuú])- rrastr
([aA])ssim sí
([oO])bjet- bject
((?:[rR]e|[dD]es)?)([aA])to(s?) cto
((?:[rR]e|[dD]es)?)([aA])ç(ão|ões) cç
((?:[rR]e|[dD]es)?)([aA])cion- ccion
((?:[rR]e|[dD]es)?)([aA])tiv- ctiv
((?:[rR]e|[dD]es)?)([aA])tua(l|i|idade)(s?) ctua
((?:[rR]e|[dD])?)([eE])strutur- structur
((?:[aA]uto|[rR]e|[dD]es)?)([cC])arreg- arg
([pP]ro)v- b
((?:[dD]es)?)([aA]pro)v- b
([rR]ec)ebe([sm]?) ibe
([rR]ec)eb[ée]- ibi
([rR]ec)eb- ib
ecrã(s?) pantalla
Ecrã(s?) Pantalla
([eE]le)i(ç)- c
([fF])undo(s?) ondo
Frango(s?) Polo
frango(s?) polo
([hH])omem ome
([oO])ntem nte
Mãe(s?) Nai
mãe(s?) nai
Já Xa
já xa
([oO])ntem nte
Cena(s?) Escena
cena(s?) escena
Cenário(s?) Escenário
cenário(s?) escenário
([oO]rd)em e
([oO]rd)ens es
([cC])oluna(s?) olumna
([cC])ristão(s?) ristián
([cC])ristã(s?) ristiá
([dD])ê ea
([dD])ois ous
([dD])ívida(s?) ébeda
([dD])isponív- ispoñíb 
([fF])aculdade(s?) acultade
([fF])ormatação ormato
([fF])ormatações ormatos
([fF]r)ut([ao])(s?) oit
([cC]h)uva(s?) oiva
([lL])uta(s?) oita
Item(s?) Elemento
item(s?) elemento
([oO])xig[êé]nio(s?) síxeno
([tT])u i
((?:d|n|d?aqu)?)ele el
Ele El
([sS])ozinh- oíñ
([vV])ocê(s?) ostede
([pP])el([oa]s?) ol
((?:sobre)?)tudo(s?) todo
([cC])ampeã(s?) ampiona
([cC])ampe(ão|ões) ampi
((?:[cC]apit|[eE]st|[iI]rm|[aA]lem|[cC]rist)?)ão(s?) án
((?:[cC]ora|[dD]oa|[hH]iperliga|[lL]iga)?)ção zón
((?:[cC]ora|[dD]oa|[hH]iperliga|[lL]iga)?)ções zóns
((?:[cC]apit|[iI]rm|[aA]lem|[cC]rist)?)ã(s?) á
([Ll])has hela
([Ll])hos helo
([nN])em in
([cC])onteúdo(s?) ontido
([cC])ontrole(s?) ontrol
quais cales
Quais Cales
([dD])ireit- ereit
([rR]e?)([eE])leit([oa])(s?) lect
Fech- Pech
fech- pech
?([gG])uard- ard
([gG])rau(s?)- rao
([hHjJ]o[mv])ens es
Hierarqui- Xerarqui
hierarqui- xerarqui
Hierárquico(s?) Xerárquico
hierárquico(s?) xerárquico
([jJ])ovem ove
([mM])uçulmano(s?) usulmán
([mM])uçulmana(s?) usulmá
([pP])ont(o?|os?|u?)- unt
([pP])propriedade(s?) ropiedade
([pP])rópri- rópi
([aA]p)ropri- ropi
Pasta Cartafol
Pastas Cartafoles
pasta cartafol
pastas cartafoles
([pP])aine(l|is) ane
Qualquer Calquera
Quaisquer Calquera
qualquer calquera
quaisquer calquera
Quase Case
quase case
Quarto(s) Cuarto
quarto(s) cuarto     
Sob Baixo
sob baixo
-casião casión
-artão artón
-belhão belhón
-amarão amarón
-egião egión
Sabão Xabón
sabão xabón
Sabões Xabóns
sabões xabóns
-atrão atrón
([rR])ota(s)? uta  
([aA])lmoç- lmorz     
([tT])rês res
([dD])epois espois
([mM])ais áis
([mM])as ais
([mM])eio édio
([nN])ível ivel
([mM])ui oi
([mM])uit([oa]s?) oit
([pP])essoa([ls]?|is?) ersoa
?(ór)([bpdtkvgfcçzkjxslmnr])ão(s?) ao
((?:[cCdDhHmMpPtTvV])?)ão(s?) an
((?:[cCdDhHmMpPtTvV])?)ães ans
([cC]h)ão(s?) an
([nsNS])ão on
([tT])ambém amén
([aA])ssim s
([eEoO])xig([ei)- six
Enquanto Mentres
enquanto mentres
([gG])rau(s?) rao    
([cC]re)sc- c
([nN]a)sc- c
([cC]orr|[eE]l)e([gj])- i
([cC]orri|[eE]li)ge- gi
([cC]orri|[eE]li)gê- gí
([cC]on|[dD]i)vir([gj])- ver
([cC]onver|[dD]iver)gi- ge
([cC]onver|[dD]iver)gí- g
([cC]r)i(ação|ações) e
([dD])ormi- urmi
([dD])ormi urmi
([cC]|[eE]nc|[dD]esc)obri- ubri
([cC]|[eE]nc|[dD]esc)obri ubri
([eE]|[sS]obre)stej- ste
?screver scribir
?screver- scribir
?screveu((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) scribiu
?screv- scrib
?([vV])iver ivir
?([vV])iver- ivir
?([vV])iveu((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) iviu
([cC])onceber oncibir
([cC])onceber- oncibir
([cC])oncebeu((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) oncibiu
([cC])onceb- oncib
([rR])ecever ecibir
([rR])ecever- ecibir
([rR])eceveu((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) ecibiu
([rR])ecev- ecib
([sS])ou((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) on
([fF])ui((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) un
([fF])oste((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uches
((?:[aA]|[aA]bs|[eE]s|[cC]on|[dD]e|[mM]an|[oO]b)?)[tT]eve((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) tivo
((?:[aA]|[aA]bs|[eE]s|[cC]on|[dD]e|[mM]an|[oO]b)?)[tT]ive((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) tivem
([tT])ens((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) es
((?:[aA]|[aA]bs|[eE]s|[cC]on|[dD]e|[mM]an|[oO]b)?)téns((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) tés
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))aç((?:o|a|as|amos|am|ais)?)((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) ag
?([fF])azemos((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) acemos
([fF])azem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) an
([fF])azes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) as
?([fF])azê-lo(s?) acé-lo
([fF])á-lo(s?) aino    
((?:[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))azem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) án
((?:[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))azes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ás
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))aze((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ai
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))iz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixen
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))ez((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixo
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))iz((?:este|emo(s?)|eram|éreis|ésseis|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?)|er|eres|erdes|erem)?)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ix
([hH])á((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ai
([hH])ás((?:-m|-lh|-t|-ch|-v|-n|-s)?([eoa]?(s?))) as
([hH])á-l([oa](s?)) a-l
((?:[pP]|[aA]ntep|[dD]ep|[dD]ecomp|[Dd]isp|[pP]rop|[Dd]ep|[sS]uperp|[sS]up))ôs((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uxo
((?:[pP]|[aA]ntep|[dD]ep|[dD]ecomp|[Dd]isp|[pP]rop|[Dd]ep|[sS]uperp|[sS]up))us((?:este|emos|eram|era(s?)|éramos|esse(s?)|éssemos|essem|er|eres|erdes|erem|éreis|ésseis)?)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ux
((?:[pP]|[aA]ntep|[dD]ep|[dD]ecomp|[Dd]isp|[pP]rop|[Dd]ep|[sS]uperp|[sS]up))ux uxem
([pP])erc((?:o|a|as|amos|am|ais)?)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) erd
((?:[eE]s|[cC]on|[dD]e|[mM]an|[oO]b)?)[tT]êm((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) teñen
([vV])êm((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) eñen
((?:[aA]ntev|[pP]rev|[rR]ev|[rR]el|[dD]escr|[eE]ntrev))êem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) én
((?:[aA]ntev|[pP]rev|[rR]ev|[rR]el|[dD]escr|[eE]ntrev))ê((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) é
((?:[vV]|[lL]|[cC]r))êem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) en
((?:[vV]|[lL]|[cC]r))ê((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) e
((?:[lL]|[cC]r))ei((?:amos|ais))((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) e
((?:[vV]|[lL]|[cC]r))i((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) in
([dD])êem eam
((?:[pP]oss|[eE]vol|[cC]onstr|[dD]estr|[rR]econstr|[aAtrib]|[oO]bstr|[cC]oncl|[dD]istrib|[iI]ncl))uis((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) úes
((?:[pP]oss|[eE]vol|[cC]onstr|[dD]estr|[rR]econstr|[aAtrib]|[oO]bstr|[cC]oncl|[dD]istrib|[iI]ncl))ui((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) úe
((?:[cC]ons|[dD]es|[rR]econs))tróis((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) trúes
([cC]ons|[dD]es|[rR]econs)trói((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) trúe
((?:[cC]ons|[dD]es|[rR]econs))troem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) trúem
((?:[cC]onstr|[dD]estr|[rR]econstr|[aAtribtr]|[oO]bstr|[cC]oncl|[dD]istrib|[iI]ncl))ui((?:mos|ram|ra(s?)|esse(s?)|essem|res|rdes|rem|u|stes)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) uí
([vV])ais((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) as
([vV])á((?:s)?)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) aia
((?:[aA]dv|[cC]onv|[iI]nterv|[pP]rov|[dD]esav|[sS]obrev))ais((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ás
((?:[vV]|[aA]dv|[cC]onv|[iI]nterv|[pP]rov|[dD]esav|[sS]obrev))ens((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) és
([vV])eio((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) eu
((?:[vV]|[aA]dv|[cC]onv|[iI]nterv|[pP]rov|[dD]esav|[sS]obrev))i(emos|este(s?)|eram|era(s?)|éramos|esse(s?)|éssemos|essem|er|eres|erdes|erem|éreis|ésseis)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) iñ
([vV])iñeste iñeches
ansei((?:o|a(s?)|[ea]m|e(s?))?) ánsi
ansei((?:o-|a(s?)-|am-)?) ánsi
([aA])nsei(amo|[aá]v|[aá]r|ast)- nsi
([iI])ncendei((?:o|a(s?)|[ea]m|e(s?))?) ncéndi
([iI])ncendei((?:o-|a(s?)-|am-)?) ncéndi
([iI])ncendei(amo|[aá]v|[aá]r|ast)- ncendi
odei((?:o|a(s?)|[ea]m|e(s?))?) ódi
odei((?:o-|a(s?)-|am-)?) ódi
([oO])dei(amo|[aá]v|[aá]r|ast)- di
((?:[mM]|[rR]em))edei((?:o|a(s?)|[ea]m|e(s?))?) édi
((?:[mM]|[rR]em))edei((?:o-|a(s?)-|am-)?) édi
((?:[mM]|[rR]em))edei(amo|[aá]v|[aá]r|ast)- edi
([pP])ro([ií]b)- roh
([pP])ôde((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uido
([pP])ude((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uidem
([pP])osso((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) odo
([pP])oss(a(s?)|mo(s?)|m|ais)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) oid
([pP])ude- uide
([pP])udé- uidé
((?:[pP]|[dD]esp|[iI]mp|[eE]exp||[dD]esimp|[rR]eexp|[mM]|[dD]esm))eç(|a(s?)amo(s?)|am|ais)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) id
((?:[pP]|[dD]esp|[iI]mp|[eE]exp||[dD]esimp|[rR]eexp|[mM]|[dD]esm))eço((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ido
((?:[pP]|[aA]nte|[dE]e|[dD]ecom|[iI]dis|[pP]prop|[pP]os|[sS]uperp|[sS]up))ões((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) os
((?:[pP]|[aA]nte|[dE]e|[dD]ecom|[iI]dis|[pP]prop|[pP]os|[sS]uperp|[sS]up))õem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) oñen
((?:[pP]|[aA]nte|[dE]e|[dD]ecom|[iI]dis|[pP]prop|[pP]os|[sS]uperp|[sS]up))õe((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) on
((?:[dD]|[bB]end|[cC]ond|[cC]ontrad|[pP]re|[mM]ald|[dD]esd))izei(s?) icide
((?:[dD]|[bB]end|[cC]ond|[cC]ontrad|[pP]re|[mM]ald|[dD]esd))izemos icimos
([dD])izes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) is
([dD])iz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) i
([dD])izem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) in
((?:[bB]end|[cC]ond|[cC]ontrad|[pP]re|[mM]ald|[dD]esd))izes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ís
((?:[bB]end|[cC]ond|[cC]ontrad|[pP]re|[mM]ald|[dD]esd))iz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) í
((?:[bB]end|[cC]ond|[cC]ontrad|[pP]re|[mM]ald|[dD]esd))izem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ín
((?:[dD]|[bB]end|[cC]ond|[cC]ontrad|[pP]re|[mM]ald|[dD]esd))ize- ici
([eE])scut- scoit
([pP])ergunt- regunt
([dD])iss((?:e|este|emo(s?)|eram|éreis|ésseis|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?))?)((?:-m[eoa]?(s?)|-lh[eoa]?(s?)|-t[e]?(s?)|-ch[eoa]?(s?)|-v[o]?(s?)|-n[o]?(s?)|-se|(s?)-o(s?)|-a(s?))?) ix
([dD])ixe((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixo
((?:[qQ]|[rR]eq))uer((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) uere
((?:[qQ]|[rR]eq))uis((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uixo
((?:[qQ]|[rR]eq))uis((?:este|emo(s?)|eram|éreis|ésseis|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?)|er|eres|erdes|ermos|erem)?)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uix
([tT])raz((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) rae
([tT])raz([íe])- ra
([tT])raz([ê]-)- ra
([tT])razi- raí
([tT])rag((?:o|a|as|amos|am|ais)?)((?:-m|-lh|-t|-ch|-v|-n|-o|-a)?([eoa]?(s?))) rai
([tT])rouxe((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) rouxem
((?:[tT]roux|[pP]ux|[dD]ix))este((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) eches
([fF])azem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) an
([fF])azes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) as
((?:[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))azem((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) án
((?:[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))azes((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ás
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))az((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ai
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))iz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixen
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))ez((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ixo
((?:[fF]|[sS]atisf|[lL]iqüef|[dD]esf|[cC]ontraf|[rR]aref|[rR]ef))iz((?:este|emo(s?)|eram|éreis|ésseis|esse(m|s?)|éssemo(s?)|era(m|s?)|éramo(s?)|er|eres|erdes|erem|ermos)?)((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) ix
-duz((?:-m|-lh|-t|-ch|-v|-n|-s|-o|-a)?([eoa]?(s?))) uce
((?:[cC]a|[aA]tra|[sS]a|[sS]obresa|[dD]istra))i(s?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) e 
((?:[sS]a|[sS]obresa))iu((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) íu
((?:[cC]a|[eE]sva|[aA]tra|[dD]istra))iu((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) eu
((?:[sS]a|[sS]obresa))i((?:sse(m|s?)|ra(m|s?)|res|rem|rmos)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) í
((?:[cC]a|[eE]sva|[aA]tra|[dD]istra|[dD]escontra))i((?:res|rem|rmos|rdes)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) e
((?:[cC]a|[eE]sva|[aA]tra|[dD]istra|[dD]escontra))í((?:sse(m|s?)|r|ra(m|s?)|res|rem|rmos|rdes))((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) e
((?:[cC]a|[eE]sva|[aA]tra|[dD]istra|[dD]escontra))í((?:sse(m|s?)|r|ra(m|s?)|res|rem|ssemos|sseis|ramos|rais))((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) é
((?:[cC]a|[eE]sva|[aA]tra|[dD]istra|[dD]escontra))ís((?:sse(m|s?)|ra(m|s?)|res|rem|rmos)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) edes
((?:[dD]|[mM]|[rR]|[rR]em))ôo((?:sse(m|s?)|ra(m|s?)|res|rem|rmos)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) oio
((?:[dD]|[mM]|[rR]|[rR]em))ói((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) oe
((?:[mM]|[rR]))o((?:a(m|s?)|amos|ais))((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) oi
?scer((?:ia(m|s?)|íamo(s?)|íeis|a(m|s?)|es|em|mos)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) cer
?sc((?:este|ia(m|s?)|íamo(s?)|emo(s?)|ésseis|esse(m|s?)|éssemo(s?))?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) c
([aA])rgúi((?:s)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) rgüe
((?:[aA]d|[aA]dv|[dD]iv|[cC]onf|[dD]if|[iI]nf|[pP]ref|[pP]rof|[rR]ef|[tT]ransf|[cC]omp|[rR]ep|[cC]onc|[dD]isc|[dD]ig|[iI]ng|[sS]ug|[iI]ns|[rR]efl|[mM]|[pP]|[vV]|[iI]nv|[rR]ev|[rR]equ))e((?:re|rte|te|cte|ste|rne|de))((?:s|m)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) i
espe((?:s|m)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) ispe
Espe((?:s|m)?)((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) Ispe
?([cC]onstit)ui([sm]?) úe
?([lL])ingue(s?) ingüe
?([lL])inguis- ingüis
?([lL])inguís- ingüís
?([pP])rópr- róp
([mM])uit- oit
([cC])oisa(s?) ousa
([mM])au(s?) alo
([mM])á(s?) ala
Relatório(s?) Informe 
relatório(s?) informe
([rR])epto(s?) eto 
([tT])abela(s?) áboa 
([sS])om(a|ar|a-) um
([uU])tente(s?) suário
([jJ])uiz(es|a|as?) uíz
Qua- Ca
qua- ca
Quo- Co
quo- co
([gG]est)ão ón
Gest- Xesti
gest- xesti
([qQ]uest)ão ión
Questi?- Cuesti
questi?- cuesti
([fF])requ(ên|en)- recu
([gG])ov- ob
([hH]a|[dD]e)v- b
([hH]ou)v- b
([dD])ebolv- evolv
([AaEeOoUu])i([lrnm])([bpdtkvgfcçzkjxs])- í
?([bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMjJxXsShH])([aeou])i([lrnm])([bpdtkvgfcçzkjxs])- í
-([aeou])id([oa])(s?) íd
?([AaEeOoIi])u([lrnm])([bpdtkvgfcçzkjxs])- ú
?([uU]ni)ão ón
([oO]pini)ão ón
([rR]az)ão ón
([eE]nt)ão ón
([lL]adr|[mM]ilh|[cC]art)ão ón
-(u)ição ción
-(u)ições cións
-([çs])ão ión
-([çs])ões ións
-õe(s?) ón
-ães áns
-([j])ão(s?) ón
-(ch)ão(s?) ón
-rrão rrón
-rão rán
-ão(s?) án
-ã(s?) á
-eio(s?) eo
-eia(s?) ea
-eia(m?) ea
-eie(s?) ee
-eie(m?) ee
-imento(s?) emento
-ói([oa])(s?) oi
-([aei])ram ron
-(g)em e
-(g)ens es
-([áéíóú])vel bel
-([áéíóú])veis beis
-(a|á)va((?:s|mo(s?)|m)?) ba
-(a|á)va((?:s|mo(s?)|m)?-)- ba
-ámos amos
-éu eu
-m n
-nh- ñ
-ss- s
-vr- br
-[ei]ste((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) iches
-aste((?:-m[eoa](s?)|-lh[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?))?) aches
-(g)ens es
?lh- ll
?[çz]([eiéí])? c
?g([eiéíêî])? x
?[ÇZ]([ei])? C
?G([eiéíêî])? X
([nN])eñun ingún
([nN])eñuma ingunha
((?:[nN]|[dD]|[cC]|[dD]?alg)?)[uU]mh?a(s?) unha
([Ss])ozinh oíñ
([Ss])ão-([\w]+)- om-
([Ss])ou-([\w]*)- om-
([dDvV])ão-([\w]+)- am-
-rão-([\w]+)- rám-
-m-n(o|a|as|os) n-
-m-([\w]*)- n-
-i-l(o|a|as|os) í-l
-([bBdDtTpPkKvVfFcCçÇzZkKlLrRnNmMjJxXsShH])i(-m[eoa](s?)|-ll[eoa](s?)|-ll[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?)) ín
-([gq]u)i(-m[eoa](s?)|-ll[eoa](s?)|-ll[eoa](s?)|-t[eoa](s?)|-ch[eoa](s?)|-vos|-nos|-vo-lo|-no-lo|-se|-o(s?)|-a(s?)) ín
pós-- post
);

# OPTIMIZATION: Precompile the main array of regex rules before reading lines
my @compiled_rules;
for (my $i=0; $i < @l; $i+=2) {
    my $a = $l[$i];
    my $b = $l[$i+1];
    $a =~ s/^([^\?-])/$NaoChar$1/;
    $a =~ s/([^\?-])$/$1$NaoChar/;
    $a =~ s/(^-|-$)/$WChar/gi;
    $a =~ s/(^\?|\?$)/(.)/gi;
    $a =~ s/\)\(//gi;
    push @compiled_rules, { re => qr/$a/, repl => $b };
}

my $line;
while ($line = <>) {
    chomp $line;
    $line = " $line ";
    
    $line =~ s/ /  /g;
    $line =~ s/\. / \. /g;
    $line =~ s/\.\. \. / \.\.\. /g;
    $line =~ s/\.$/ \. /g;
    $line =~ s/\, / \, /g;
    $line =~ s/\; / \; /g;
    $line =~ s/\?/ \? /g;
    $line =~ s/\!/ \! /g;
    $line =~ s/\[/ \[ /g;
    $line =~ s/\]/ \] /g;
    $line =~ s/\(/ \( /g;
    $line =~ s/\)/ \) /g;
    $line =~ s/\"/ \" /g;
    $line =~ s/([\"\{\}\\\/\«\»\‘\’]])/ $1 /g;
    
    ##First Part
    # OPTIMIZATION: Use the precompiled rules here instead of computing them
    foreach my $rule (@compiled_rules) {
        my $re   = $rule->{re};
        my $repl = $rule->{repl};
        $line =~ s/$re/$1$repl$2/g;
    }
    
    #trocas de mais duma palavra (contracções prep+art e outros...)
    $line =~ s/ con  a(s?) /coa$1 /gi;
    $line =~ s/ con  o(s?) /co$1 /gi;
    $line =~ s/ con  unha(s?) /cunha$1 /gi;
    $line =~ s/ con  un(s?) /cun$1 /gi;
    $line =~ s/ de  unha(s?) /dunha$1 /gi;
    $line =~ s/ de  un(s?) /dun$1 /gi;
    $line =~ s/ en  unha(s?) /nunha$1 /gi;
    $line =~ s/ en  un(s?) /nun$1 /gi;
    $line =~ s/ através /a través /gi;
    $line =~ s/ (de|polo)[ ]+fato /$1 feito /gi;
    $line =~ s/ (o|um|algum|este|esse|aquel)[ ]+([$w]*)?[ ]+(da)do /$1 $2 $3to /gi;
    $line =~ s/ (os|uns|alguns|estes|esses|aqueles)[ ]+([$w]*)?[ ]+(da)dos /$1 $2 $3tos /gi;
    $line =~ s/ (d|n|pol)(o|um|algum|este|esse|aquel)[ ]+([$w]*)?[ ]+(da)do /$1$2 $3 $4to /gi;
    $line =~ s/ (d|n|pol)(os|uns|alguns|estes|esses|aqueles)[ ]+([$w]*)?[ ]+(da)dos /$1$2 $3 $4tos /gi;
    
    ##Son Paulo -> San Paulo
    $line =~ s/ Son[ ]+([A-ZÁÉÍÓÚ][$w]+)/ San $1/g;
    
    #trocas de grafias especiais
    $line =~ y/çàãõâêôûjÇÀÃÕÂÊÔÛJ/záaoáéóúxZÁAOÁÉÓÚX/;
    
    #troca os futuros com pronomes proclíticos: dar-lhes-emos por daremoslhes.
    $line =~  s/á-(l[oa]s?)-([$w]+)/a-$1-$2/i ;
    $line =~  s/é-(l[oa]s?)-([$w]+)/e-$1-$2/i ;
    $line =~  s/í-(l[oa]s?)-([$w]+)/i-$1-$2/i ;     
    $line =~  s/ó-(l[oa]s?)-([$w]+)/o-$1-$2/i ;
    $line =~  s/ú-(l[oa]s?)-([$w]+)/u-$1-$2/i ;
    
    $line =~  s/-l([oa]s?)-eis/rédel-$1/gi;  
    $line =~  s/-l([oa]s?)-íeis/riédel-$1/gi;  
    $line =~  s/-(l[oa]s?)-(ás|emos|ias|íamos)/r$2-$1/gi;
    $line =~  s/-l([oa]s?)-(ei|án|á|ian?)/r$2-$1/gi;   
    $line =~  s/s-l([oa]s?)/-l$1/gi;
    
    $line =~  s/-([$w]+)-eis/rédel-$1/gi;  
    $line =~  s/-([$w]+)-íeis/riédel-$1/gi;  
    $line =~  s/-([$w]+)-(ás|emos|ias|íamos)/$2-$1/gi;
    $line =~  s/-([$w]+)-(ei|án|á|emos|ian?)/$2-$1/gi;

    $line =~ s/  / /g;
    $line =~ s/^ //g;
    $line =~ s/ $//g;

    #regras de acentuação:
    my @listPals;
    my $p;
    (@listPals) = split (" ", $line);
    $line="";
    
    foreach $p (@listPals) {
       
       # OPTIMIZATION: Appended the `/o` flag to invariant regexes inside this hot loop
       ##comia, tio, ...
       if ( ($p !~ /$vogalacentuada/o) && 
           ( ($p =~ /$cons(i[aoe])([ns]?)($symbol?)$/io) ||
             ($p =~ /[qg](ui[aoe])([ns]?)($symbol?)$/io) ) )   {

           $p =~ s/i([aoe])([ns]?)($symbol?)$/í$1$2$3/i;
       }
       ##sua, possuo, crua, ...
       elsif (($p !~ /$vogalacentuada/o) && 
           ($p =~ /$cons(u[aoe])([ns]?)($symbol?)$/io) ) {

           $p =~ s/u([aoe])([ns]?)($symbol?)$/ú$1$2$3/i

      }
       ## aqui/latim/tabu, ...
       elsif (($p !~ /$vogalacentuada/o) && 
           (length($p) >= 4) && 
           ($p !~ /(tui|$decrecente)(s?)($symbol?)$/io) &&
           ($p !~ /^($GR)[aeiou]([nmsx]?)(s?)($symbol?)$/io) ) {

           $p =~ s/i([nmsx]?)($symbol?)$/í$1$2/i;
           $p =~ s/u([nmsx]?)($symbol?)$/ú$1$2/i;
      }
       ##táxi/júri/bônus
       elsif (($p =~ /$vogalacentuada/o) && 
           (length($p) >= 4) && 
           ($p =~ /$cons(i|u)(s?)($symbol?)$/io) ) {
           $p =~ y/áéíóú/aeiou/;
       }
        ##/tênue/régua (ditongo crecente...)
       elsif ( ($p =~ /$vogalacentuada/o) && 
               ( ($p =~ /$cons($crecente)([sn]?)($symbol?)$/io) ||
                 ($p =~ /[qg]ui[ao]([sn]?)($symbol?)$/io) ) ) {
            $p =~ y/áéíóú/aeiou/;
       }
        ##/espanhóis/caracóis
       elsif ($p =~ /óis($symbol?)$/i) {
           $p =~ s/óis($symbol?)$/ois$1/i;
       } 
        ##/sair/constituir
       if (($p !~ /$vogalacentuada/o) 
           && ($p =~ /$cons(ui|ai|ei)([rln])($symbol?)$/io)  ) {
           $p =~ s/i([rln])($symbol?)$/í$1$2/i;
           $p =~ s/u([rln])($symbol?)$/ú$1$2/i;
       }

       my $des="";
       my $raiz="";
       my $v="";
       my $first="";
       my $last="";

       ##pronomes compostos: no-las, se-me
       if (($p =~ /[$w]+\-[$w]+\-[$w]+/io) && ($p !~ /[0-9]+\-[0-9]+\-[0-9]+/i) ) {
           ($raiz, $des) = ($p =~ /([$w]+)-([^ ]+)/io);
           if ( ($raiz ne "") && ($des ne "")) {        
               # OPTIMIZATION: Replaced index lookup with hash existence check
               if (exists $pronComposto{$des} || exists $pronComposto{lc($des)}) {
                 $des =~ s/-//i;
                 $p = $raiz . "-" . $des;
               } 
            }  
       }
       elsif (exists $pronComposto{$p} || exists $pronComposto{lc($p)}) {
             $p  =~ s/-//;
       }

        ## acentos de verbos com pronomes: chamo-me > chámome
       if (($p =~ /[$w]+\-[$w]+$/io) && ($p !~ /[0-9]+\-[0-9]+/i) && ($p !~ /[$w]+\-[$w]+\-[$w]+/io)) {
           ($raiz, $des) = ($p =~ /([$w]+)-([$w]+)/io);

          ##comiches + o/os
          if ( ($raiz =~ /s$/) && ($des =~ /^[ao]/)) {
              ($raiz =~ s/s$//);
              ($des =~ s/([oa]s?)/l$1/);
           } 
           
           if ( ($raiz ne "") && ($des ne "")) {
              ($des =~ s/llos/llelo/i);
              ($des =~ s/llas/llela/i); 

             if (exists $pron{$des} || exists $pron{lc($des)}) {

              if ( ($raiz !~ /$vogalacentuada/o) && ($raiz =~ /[$w]*[$consAll][$vogal][$consAll]+[$vogal]([ns]?)$/io) ) {     
                   ($first, $v, $last) = ($raiz =~ /([$w]*)([$vogal])([$consAll]+[$vogal]([ns]?))$/io);

                   if ($v ne "") {
                       $v = PorAcento($v);
                       $p = $first . $v .  $last . $des;
                   }
               }
              elsif ( ($raiz !~ /$vogalacentuada/o) && ($raiz =~ /([$w]*)${decrecente}[$w]*[$vogal]([ns]?)$/io) ) {     
                   ($first, $v, $last) = ($raiz =~ /([$w]*)([$vogal])([$vogal][$w]*[$vogal]([ns]?))$/io);

                   if ($v ne "") {
                       $v = PorAcento($v);
                       $p = $first . $v .  $last . $des;
                   }
               }
              elsif ( ($raiz !~ /$vogalacentuada/o) && ($raiz =~ /([^ ]+)[qg]u[$vogal]$/io) ) {        
                   ($first, $v, $last) = ($raiz =~ /([^ ]*)([$vogal])(([$consAll]?)[qg]u[$vogal])$/io);
                   if ($v ne "") {
                       $v = PorAcento($v);
                       $p = $first . $v . $last . $des;
                    }
               }

              elsif ( ($raiz !~ /$vogalacentuada/o) && ($raiz =~ /[$vogal][$vogal]$/io) &&
                      ($raiz !~ /$decrecente$/o) && ($raiz !~ /oio|aio$/) &&
                       ($raiz !~ /[qg]u[$vogal]$/io) 
                 )  {        
                     ($first, $v, $last) = ($raiz =~ /([^ ]*)([$vogal])([$vogal])$/io);
                     if ($v ne "") {
                       $v = PorAcento($v);
                       $p = $first . $v . $last . $des;
                    }
               }

              elsif  ( ($raiz =~ /$vogalacentuada([ns]?)$/o) && ($raiz !~ /^é|^dá([ns]?)$/i) ) {
                   ($first, $v, $last) = ($raiz =~ /([$w]*)($vogalacentuada)([ns]?)$/io);
                   if ($v ne "")  {
                       $v = TirarAcento($v);
                       $p = $first . $v . $last . $des;
                   }
             }
             elsif ($raiz =~ /$vogalacentuada/o) {
                      $p = $raiz . $des;
             }
             ##raiz acaba em ditongo crecente : por acento na primeira vogal
             elsif ( ($raiz =~ /$crecente[ns]?$/o) && ($raiz !~ /que$|gue$/i) &&
                     ($raiz !~ /oio|aio$/) ) {
                ($raiz =~ s/([$w]+)i([aeo][ns]?$)/$1í$2/io);
                ($raiz =~ s/([$w]+)u([aeo][ns]?$)/$1ú$2/io);
                 $p = $raiz . $des;
             }
            elsif ( ($raiz =~ /$decrecente$/o) &&  ($des =~ /^[oa]/i) ){
                      $p = $raiz . "n" . $des;
             }
            else {
                  $p = $raiz . $des;
              }
           }
        }
       }

    ## corrigir acentos verbos:
      $p =~ s/á(bamos|bades|bamol|badel)/a$1/;
      $p =~ s/á(ramos|rades|ramol|radel)/a$1/;
      $p =~ s/á(semos|sedes|semol|sedel)/a$1/;
      $p =~ s/í(amos|ades|amol|adel)/i$1/;
      $p =~ s/é(semos|sedes|semol|sedel)/e$1/;
      $p =~ s/é(ramos|rades|ramol|radel)/e$1/;
      $p =~ s/í(ramos|rades|ramol|radel)/i$1/;
      $p =~ s/í(semos|sedes|semol|sedel)/i$1/;
      $p =~ s/ú(ñamos|ñades|ñamol|ñadel)/u$1/;
      $p =~ s/í(ñamos|ñades|ñamol|ñadel)/i$1/;
      $p =~ s/ó(semos|sedes|semol|sedel)/o$1/;
      
      ## Metacorrecções:
      $p =~ s/^([cC])ontrache/$1ontraste/i;
      $p =~ s/^([nNdDlL])iches$/$1este/i;
      $p =~ s/^([eE])xiches$/$1xiste/i;
      $p =~ s/^([lL])inúx$/$1inux/i;
      $p =~ s/^([xX])aba$/Java/i;
      $p =~ s/^([mM])aíl$/$1ail/i;
      $p =~ s/^([cC])orpús$/$1orpus/i;
      $p =~ s/^([pP])lug-ín$/$1lug-in/i;
      $p =~ s/^([fF])unctíon$/$1unction/i;
      $p =~ s/^([aA])rraches$/$1rrastre/i;
      $p =~ s/^([óÓ])rgao/$1rgano/i;
      $p =~ s/^Órgán(s?)/Órgano$1/i;
      $p =~ s/^([pP])oída/$1oida/i;
      $p =~ s/bolución$/volución/i;
      
      ##reíntrodr
      $p =~ s/^([Rr])eín$/$1ein/i;
      $p =~ s/^([qQ])ueiron$/$1ueiran/i;
      $p =~ s/^([fF])iron$/$1iran/i;
      $p =~ s/^([sS])orrín$/$1orrí/i;
      $p =~ s/^([sS])entencía$/$1entencia/i;
      $p =~ s/^([hH])oube$/$1oubo/i;
      $p =~ s/^([cC])oíncid/$1oicind/i;
      $p =~ s/^([pP])iche/$1este/i;
      $p =~ s/^([pP])istes/$1estes/i;
      $p =~ s/^([aA])lemento(s?)/$1limento$2/i;
      $p =~ s/^([cC])ondemento(s?)/$1ondimento$2/i;
      $p =~ s/^([dD])etremento(s?)/$1etrimento$2/i;
      $p =~ s/^([eE])xperemento(s?)/$1xperimento$2/i;
      $p =~ s/^([iI]mpedemento)(s?)/$1mpedimento$2/i;
      $p =~ s/^([pP])avemento(s?)/$1avimento$2/i; 
      $p =~ s/^([pPsS])edemento(s?)/$1edimento$2/i;
      $p =~ s/^([pP])ulemento(s?)/$1ulimento$2/i;
      $p =~ s/^([rR])udemento(s?)/$1udimento$2/i;
      $p =~ s/([aA])probeit/$1proveit/i;
      $p =~ s/([fF])ixiches/$1ixeches/i;
      
      $line .= $p . " ";
    }

    my $SpecialChar = "\?\!\¿\¡\%\&\/\(\)\\\+\*\'\=\.\,\;\:";
    
    $line =~ s/ \. /\. /g;
    $line =~ s/ \; /\; /g;
    $line =~ s/ \, /\, /g;
    $line =~ s/ \? /\? /g;
    $line =~ s/ \! /\! /g;
    $line =~ s/\[ /\[/g;
    $line =~ s/ \] /\] /g;
    $line =~ s/\( /\(/g;
    $line =~ s/ \) /\) /g;
           
    $line =~ s/\" ([\w ]+) \"/\"$1\"/g;
    $line =~ s/ ([\]\)\"])([\W])/$1$2/g;

    ##Second Part
    print "$line\n";
}

# OPTIMIZATION: Much faster hash lookup
sub PorAcento {
    return $add_accent{$_[0]} || $_[0];
}

sub TirarAcento {
    return $strip_accent{$_[0]} || $_[0];
}

