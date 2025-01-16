//
//  Constants.swift
//  Tracker
//
//  Created by Aleksei Frolov on 16.11.2024.
//

import Foundation

enum Constants {
    static let tabBarItemTrackers = "Трекеры"
    static let tabBarItemStatistic = "Статистика"
    
    static let trackersVcTitleLabel = "Трекеры"
    static let trackersVcSearchPlaceholder = "Поиск"
    static let trackersVcPlaceholderLabel = "Что будем отслеживать?"
    static let trackersVcTrackerCellId = "TrakerCell"
    static let trackersVcTrackerCategoryHeaderId = "TrackerCategoryHeader"
    static let trackersVcDeleteConfirmationAlertTitle = "Уверены, что хотите удалить трекер?"
    static let trackersVcEmptySearchPlaceholderText = "Ничего не найдено"
    static let trackersVcUserDefaultsKeyIsFirstLaunch = "isFirstLaunch"
    static let trackersVcContextMenuPinOption = "Закрепить"
    static let trackersVcContextMenuUnpinOption = "Открепить"
    static let trackersVcContextMenuEditOption = "Редактировать"
    static let trackersVcContextMenuDeleteOption = "Удалить"
    static let trackersVcPinnedCategoryTitle = "Закреплённые"
    static let trackersVcUserDefaultsKeySelectedFilter = "SelectedFilter"
    
    
    static let trackerTypeSelectionVcTitle = "Создание трекера"
    static let trackerTypeSelectionVcHabit = "Привычка"
    static let trackerTypeSelectionVcIrregularEvent = "Нерегулярное событие"
    static let trackerCellPlusButtonSystemName = "plus"
    
    static let scheduleVcTitle = "Расписание"
    static let scheduleVcReadyButtonTitle = "Готово"
    static let scheduleVcCellId = "ScheduleCell"
    
    static let eventVcCategoryTitle = "Категория"
    static let eventVcNewHabitCreationTitle = "Новая привычка"
    static let eventVcNewIrregularEventCreationTitle = "Новое нерегулярное событие"
    static let eventVcTextFieldPlaceholderTitle = "Введите название трекера"
    static let eventVcEmojiLabelTitile = "Emoji"
    static let eventVcColorLabelTitle = "Цвет"
    static let eventVcCancelButtonTitle = "Отменить"
    static let eventVcCreateButtonTitle = "Создать"
    static let eventVcTableViewCellId = "tableCell"
    static let eventVcEmojiCollectionCellId = "emojiCell"
    static let eventVcColorCollectionCellId = "colorCell"
    static let eventVcMaxNameLength = 38
    static let eventVcMaxNameLengthErrorText = "Ограничение 38 символов"
    static let eventVcClearButtonSystemName = "xmark.circle.fill"
    static let eventVcEditingHabitTitle = "Редактирование привычки"
    static let eventVcEditingIrregularEventTitle = "Редактирование события"
    static let eventVcEditingResultButton = "Сохранить"
    
    static let categoryVcPlaceholderLabel = "Привычки и события можно \nобъединить по смыслу"
    static let categoryVcAddButtonTitle = "Добавить категорию"
    static let categoryVcCategoryCell = "CategoryCell"
    static let categoryVcEditOptionTitle = "Редактировать"
    static let categoryVcDeleteOptionTitle = "Удалить"
    static let categoryVcDeleteConfirmationAlertTitle = "Эта категория точно не нужна?"
    static let categoryVcDeleteConfirmationAlertDeleteOption = "Удалить"
    static let categoryVcDeleteConfirmationAlertCancelOption = "Отмена"
    static let categoryVcLastSelectedCategoryKey = "lastSelectedCategory"
    static let categoryVcPinnedCategoryTitle = "Закреплённые"
    static let categoryVcContextMenuEditOption = "Редактировать"
    static let categoryVcContextMenuDeleteOption = "Удалить"
    
    
    static let newCategoryVcTitle = "Новая категория"
    static let newCategoryVcPlaceholder = "Введите название категории"
    static let newCategoryVcEditingCategoryTitle = "Редактирование категории"
    
    static let coreDataStackModelName = "TrackerModel"
    
    static let onboardingPageButton = "Вот это технологии!"
    static let onboardingPageBlueScreenImageName = "BlueBackground"
    static let onboardingPageBlueScreenTitle = "Отслеживайте только то, что хотите"
    static let onboardingPageRedScreenImageName = "RedBackground"
    static let onboardingPageRedScreenTitle = "Даже если это не литры воды и йога"
    static let onboardingPageUserDefaultsKey = "hasSeenOnboarding"
    
    static let contextMenuViewCell = "ContextMenuOptionCell"
    
    static let alertServiceDeleteOption = "Удалить"
    static let alertServiceCancelOption = "Отмена"
    
    static let filterViewControllerTitle = "Фильтры"
    static let filterViewControllerCell = "FilterCell"
    
    static let statisticViewControllerTitle = "Статистика"
    static let statisticVCPlaceholderText = "Анализировать пока нечего"
    static let statisticVCCompletedHabitsOption = "Трекеров завершено"
    static let statisticViewCell = "StatisticTableViewCell"    
}
