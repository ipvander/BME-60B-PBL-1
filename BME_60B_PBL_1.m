% Ian Van Der Linde, Ryan Shabbak, Trevor Holmgren
% 10/21/25
% This script creates a blackjack game

% Create and shuffle a deck of Cards
deck = repmat(1:13, 1, 4); % 13 cards, 4 suits, 52 total cards.
shuffledDeck = deck(randperm(length(deck))); % Shuffle the deck

% Create card names for dialogue
cardNames = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10",...
    "King", "Queen", "Jack"];

% Create cardValues array to store card values (will be later manipulated
% for aces)
cardValues = shuffledDeck;
cardValues(cardValues > 10) = 10;