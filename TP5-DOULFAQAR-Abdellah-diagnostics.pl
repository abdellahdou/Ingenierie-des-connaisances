:- dynamic reponse/2.

% Partie 1 : Base de connaissances statique
maladie(grippe) :- a(fievre), a(courbatures), a(fatigue), a(toux).
maladie(angine) :- a(mal_gorge), a(fievre), \+ a(toux).
maladie(covid) :- a(fievre), a(toux), a(fatigue).
maladie(allergie) :- a(eternuements), a(nez_qui_coule), \+ a(fievre).

nom(fievre, 'fievre'). nom(toux, 'toux'). nom(mal_gorge, 'mal de gorge').
nom(fatigue, 'fatigue'). nom(courbatures, 'courbatures'). nom(eternuements, 'eternuements').
nom(nez_qui_coule, 'nez qui coule').

% Partie 2 : Interaction avec l’utilisateur

a(S) :- reponse(S, oui), !.
a(S) :- reponse(S, non), !, fail.
a(S) :- \+ reponse(S, _), nom(S, N), format('~w ? (o/n): ', [N]), 
        get_char(R), get_char(_),
        (R = o -> assertz(reponse(S, oui)) ; assertz(reponse(S, non))), R = o.

% Partie 3 : Moteur d'inference avec explication

start :- write('======= DIAGNOSTIC MEDICAL ======='), nl,
          write('Repondez par o ou n (sans point).'), nl, nl,
          retractall(reponse(_, _)),
          findall(M, maladie(M), L),
          (L = [] -> write('Aucun diagnostic.'), nl
          ; write('Diagnostic(s): '), nl, afficher_avec_explication(L)).

afficher_avec_explication([]).
afficher_avec_explication([M|Reste]) :- 
    format('  - ~w', [M]), 
    expliquer(M), nl,
    afficher_avec_explication(Reste).

expliquer(_) :- 
    write(' (car: '),
    findall(N, (reponse(S, oui), nom(S, N)), Symptomes),
    afficher_liste(Symptomes),
    write(')').

afficher_liste([]).
afficher_liste([S]) :- format('~w', [S]), !.
afficher_liste([S|Reste]) :- format('~w, ', [S]), afficher_liste(Reste).

% Partie 4 : Tests avec patients fictifs

test :- write('======= TEST AVEC PATIENTS FICTIFS ======='), nl, nl,
        % Patient 1: grippe
        write('Patient 1 (grippe):'), nl,
        assertz(reponse(fievre, oui)), assertz(reponse(courbatures, oui)),
        assertz(reponse(fatigue, oui)), assertz(reponse(toux, oui)),
        (maladie(M1) -> format('  Diagnostic: ~w~n', [M1]) ; write('  Aucun diagnostic')), nl,
        retractall(reponse(_, _)),
        % Patient 2: allergie
        write('Patient 2 (allergie):'), nl,
        assertz(reponse(eternuements, oui)), assertz(reponse(nez_qui_coule, oui)),
        assertz(reponse(fievre, non)),assertz(reponse(mal_gorge, non)),
        (maladie(M2) -> format('  Diagnostic: ~w~n', [M2]) ; write('  Aucun diagnostic')),
        retractall(reponse(_, _)).

:- write('Tapez "start" pour commencer.'), nl.