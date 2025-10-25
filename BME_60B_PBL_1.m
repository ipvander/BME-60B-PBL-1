% Ian Van Der Linde, Ryan Shabbak, Trevor Holmgren 
% 10/24/25
% This script creates a blackjack game

clear all; close all; clc; % start cleared

% Create card names for dialogue
cardNames = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10",... % labels used when printing card ranks
    "Jack", "Queen", "King"]; % facecard labels

% Create the deck of cards
[deckCards, deckSuits] = createDeck(); % build one shuffled 52 card deck

% Menu asks how many are playing
numPlayers = 1 + menu('Select number of players: ', 'One', 'Two', 'Three', 'Four'); % total seats including dealer at seat 1
switch (numPlayers - 1) % repeat the selection for user feedback
    case 1 %menu case 1
      fprintf('You selected One player \n'); % 1 human + dealer
    case 2 %menu case 2
      fprintf('You selected Two players'); % 2 humans + dealer
    case 3 %menu case 3
      fprintf('You selected Three players'); % 3 humans + dealer
    case 4 %menu case 4
       fprintf('You selected Four players') % 4 humans + dealer
    otherwise %if not selected menu case
      disp('Error D:'); % fallback
end
pause(1.5); % small pause so messages are readable

% Create player and dealer hands
[playerHands, cardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits); % deal 2 cards to each seat, return next deck index

% Show initial hands making sure to hide dealers first card
for p = numPlayers:-1:1 % print from last seat to dealer so dealer shows last
    if p == 1 % dealer is seat 1 in this convention
        fprintf("\nDealer's Hand:\n"); % dealer header
        for c = 1
            fprintf("%d. Hidden\n", c) % hide the first card
        end
        for c = 2
        fprintf("%d. %s of %s \n", c, cardNames(playerHands{p}.cards(c)), ... % show only the revealed card rank
            playerHands{p}.suits(c)); % and the revealed card suit
        end
    else
        fprintf("\nPlayer %d's Hand:\n", p - 1); % user facing index (players numbered 1..N-1)
        for c = 1:2
            fprintf("%d. %s of %s \n", c, cardNames(playerHands{p}.cards(c)), ... % show both starting cards
            playerHands{p}.suits(c)); % suit for that card
        end
        playerTotal = adjustForAcesFaces(playerHands{p}.cards); % compute total using Ace's rules and face=10
        if playerTotal == 21
            fprintf ("\nBlackJack!\n"); % announce blackjack
        end
    end
end
pause(1.5); % pacing

% Going through every players turns except dealer
for p = 2:numPlayers % players act before the dealer
    [playerHands, cardIndex] = playHand(playerHands, p, deckCards,deckSuits,... % run hit/stay loop for player p
                                        cardIndex, cardNames); % returns updated hand and next deck index
    playerTotal = adjustForAcesFaces(playerHands{p}.cards); % recompute total after the turn
    if playerTotal == 21
        fprintf("Current hand total: %d\n", playerTotal); % when a player ends on 21
    end
    pause(1.5); % pacing between turns
end
pause(1.5); % pacing before dealer

% Check if all players busted
allBusted = true; % assume all busted until we find one that didn't
for p = 2:numPlayers
    playerTotal = adjustForAcesFaces(playerHands{p}.cards); % current total for player p
    if playerTotal <= 21
        allBusted = false; % at least one player is still live
        break; % no need to keep checking
    end
end

dealerTotal = adjustForAcesFaces(playerHands{1}.cards); % baseline in case dealer never needs to act

% Dealer plays last
if allBusted
    fprintf("\n All players busted! Dealer automatically wins!\n") % trivial outcome if everyone busted
else
    fprintf("\nDealer's Turn\n"); % start dealer phase
    dealerTotal = adjustForAcesFaces(playerHands{1}.cards); % dealer's starting total
    fprintf("Dealer's hand:\n"); % show both dealer cards now
    for c = 1:length(playerHands{1}.cards)
        fprintf("  %s of %s\n", cardNames(playerHands{1}.cards(c)), playerHands{1}.suits(c)); % reveal card rank and suit
    end
    fprintf("Dealer's total: %d\n", dealerTotal); % show dealer total before actions

    % Dealer hits until total >= 17
    while dealerTotal < 17 % standard dealer rule (stand on all 17)
        fprintf("Dealer hits.\n"); % narrate action
        pause(1.5); % pacing
        playerHands{1}.cards(end+1) = deckCards(cardIndex); % draw next rank
        playerHands{1}.suits(end+1) = deckSuits(cardIndex); % draw matching suit
        cardIndex = cardIndex + 1; % advance deck pointer
    
        dealerTotal = adjustForAcesFaces(playerHands{1}.cards); % recompute with Ace softening
        fprintf("Dealer drew %s of %s (total = %d)\n", ... % announce draw and updated total
            cardNames(playerHands{1}.cards(end)), playerHands{1}.suits(end), dealerTotal);
    end

    if dealerTotal > 21
        fprintf("Dealer busts!\n"); % dealer exceeded 21 then they bust
        pause(1.5); % pacing before results
    end
end
pause(2); % settle before final results

% Determine results
fprintf("\n--- Results ---\n"); % results header
for p = 2:numPlayers
    playerTotal = adjustForAcesFaces(playerHands{p}.cards); % final total for player
    fprintf("\nPlayer %d total: %d\n", p-1, playerTotal); % show player total
    fprintf("Dealer total: %d\n", dealerTotal); % show dealer total
    pause(1.5); % pacing between outputs
    if playerTotal > 21
        fprintf("Player %d busts! Dealer wins.\n", p-1); % player bust always loses
    elseif dealerTotal > 21
        fprintf("Dealer busts! Player %d wins!\n", p-1); % dealer bust then surviving player wins
    elseif playerTotal > dealerTotal
        fprintf("Player %d wins!\n", p-1); % higher non-bust total wins
    elseif playerTotal < dealerTotal
        fprintf("Dealer wins against Player %d.\n", p-1); % lower non-bust total loses
    else
        fprintf("Push! Player %d ties with the Dealer.\n", p-1); % equal totals -> push
    end
    pause(1.5); % pacing
end
pause(1.5); % final pause
fprintf("\nGame over!\n"); % end banner



function [deckCards, deckSuits] = createDeck()
% This function creates a shuffled deck of cards 
% Create cards and suits
cards = 1:13; % rank ids (1=Ace, 11=Jack, 12=Queen, 13=King)
suits = ["Spades","Hearts", "Diamonds", "Clubs"]; % suit labels

% Create a grid of 52 cards, numbers 1:13, with assigned suits 1:4
[cardsGrid, suitsGrid] = ndgrid(cards, suits); % pair each rank with each suit
deckCards = cardsGrid(:); %Creates column of card # repeated 4 times
deckSuits = suitsGrid(:); %Creates column of suits repeated 13 times each

% Shuffle the deck
order = randperm(length(deckCards)); % get random permutation 1..52
deckCards = deckCards(order); % apply shuffle to ranks
deckSuits = deckSuits(order); % keep suits aligned with ranks
end

function [playerHands, cardIndex] = dealInitialHands(numPlayers, deckCards, deckSuits)
% Deals two cards to each player (including dealer)
% Player 1 is the dealer, the rest are human players

    % Initialize a cell array for each player's hand
    playerHands = cell(1, numPlayers); % each cell holds a struct with .cards and .suits
    cardIndex = 1; % Keeps track of where we are in the deck

    % Deal two cards to each player
    for p = numPlayers:-1:1  % Count down so dealer (player 1) gets last hand
        % Each player gets 2 cards from the deck
        playerHands{p}.cards = deckCards(cardIndex:cardIndex+1); % take two ranks
        playerHands{p}.suits = deckSuits(cardIndex:cardIndex+1); % take two suits
        % Move deck index forward
        cardIndex = cardIndex + 2; % advance pointer for next seat
    end
end

function total = adjustForAcesFaces(values)
% Calculates total of hand treating Aces as 11 unless busting

    values(values > 10) = 10; % J/Q/K count as 10
    values(values == 1) = 11; % treat Ace as 11 first
    total = sum(values); % initial sum

    % Downgrade Aces to 1 if bust
    numAces = sum(values == 11); % how many Aces are currently high (worth 11)
    while total > 21 && numAces > 0
        total = total - 10; % convert one Ace from 11 to 1
        numAces = numAces - 1; % one fewer high Ace remaining
    end
end

function [playerHands, cardIndex] = playHand(playerHands, p, deckCards,deckSuits,...
                                        cardIndex, cardNames)
% Handles a single player's turn
% Input: playerHands cell array, player index, deck arrays, nextCardIndex, cardNames
% Output: updated playerHands and CardIndex

hand = playerHands{p}; % local working copy of this player's hand
total = adjustForAcesFaces(hand.cards); % start total with Ace softening

fprintf('\nPlayer %d''s turn:\n', p - 1); % announce which player is acting

while total < 21 % continue until player stands or busts
    fprintf('Current hand total: %d\n', total); % show current total
    %Menu popup for hitting or staying
    playerHit = menu('Hit or stay?', 'Hit', 'Stay'); % simple UI choice
        switch (playerHit)
            case 1
                fprintf('\nYou Hit\n'); % confirm action
                % Deal and add card to player's hand
                hand.cards(end+1) = deckCards(cardIndex); % draw next rank
                hand.suits(end+1) = deckSuits(cardIndex); % draw matching suit

                cardIndex = cardIndex + 1; % advance to next card in deck

                % Show only card name and suit
                fprintf('You drew: %s of %s\n', cardNames(hand.cards(end)), hand.suits(end)); % reveal the draw

                % Recalculate total using Ace logic
                total = adjustForAcesFaces(hand.cards); % update total after drawing

                if total > 21
                    fprintf('\nBust! Total = %d\n', total); % report bust
                    pause(1.5); % short pause before exiting
                    break; % end player turn on bust
                end
            case 2
                fprintf('\nYou Stayed\n'); % player stands on current total
                break;
            otherwise
                disp('Error D:'); % defensive fallback
        end
end

% Save updated hand
playerHands{p} = hand; % write the modified hand back to the main list
end




