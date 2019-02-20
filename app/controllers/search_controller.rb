class SearchController < ApplicationController
    require 'net/http'
    require 'uri'
    require 'openssl'
    require 'json'
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    #
    # FUNCTION TO DISPLAY THE VIEWS
    #

    # Page de formulaire de recherche
    def form
        if logged_in?
            @lastSearch = Url.joins(:user).where(user_id: session[:user_id]).limit('10').order(:id).reverse_order
            @lastSearch = @lastSearch.to_a
        end
    end

    # Page qui affiche les informations de l'utilisateur recherché
    def result
        userSearch = params[:username]

        # Si le formulaire n'est pas vide et ne contient que des caractères alphanumériques
        if userSearch != "" && !userSearch.match(/\A[a-zA-Z0-9]*\z/).nil?

            @userInfo = getInfoAboutUser(userSearch)

            # Si l'utilisateur n'est pas trouvé sur l'API de GitHub
            if @userInfo["message"] == "Not Found"
                flash[:info] = "User not found."

                redirect_to '/search'
            else
                if logged_in?
                    storeSearchInDB(userSearch)
                end

                listOfRepos = getListOfRepo(@userInfo)
                @namesOfAllRepos = getNamesOfAllRepos(listOfRepos)

                if @userInfo["type"] != "Organization"

                    jsonOfContributorsForEachRepo = getJsonOfContributorsForEachRepo(listOfRepos)
                    @numberOfContributionsForEachRepo = getNumberOfContributionsForEachRepo(jsonOfContributorsForEachRepo, @userInfo["login"])
                    totalContributionForEachRepo = getTotalContributionForEachRepo(jsonOfContributorsForEachRepo)
                    @percentageOfContributionsForEachRepo = getPercentageOfContributionsForEachRepo(@numberOfContributionsForEachRepo, totalContributionForEachRepo)

                    numberOfContributionsForEachRepoByUser = getNumberOfContributionsForEachRepoByUser(jsonOfContributorsForEachRepo)
                    @topContributorsForEachRepo =  sortContributorsByDESC(numberOfContributionsForEachRepoByUser)
                end

                @languagesForEachRepo = getLanguagesForEachRepo(listOfRepos)
                totalLanguagesForAllRepos = getTotalLanguagesForAllRepo(@languagesForEachRepo)
                @topLanguagesOfAllRepos = sortLanguagesByDESC(totalLanguagesForAllRepos)
            end
        else
            flash[:info] = "The username github can only contain alphanumeric characters and can't be empty."

            redirect_to '/search'
        end
    end

    private

    #
    # GLOBAL FUNCTION
    #

    # Depuis l'URL, récupère les données et les transforme en JSON
    def formatJSON(url)
        uri = URI(url)
        response = Net::HTTP.get(uri)
        # response.use_ssl = true
        # response.verify_mode = OpenSSL::SSL::VERIFY_NONE
        data = JSON.parse(response)
        # http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        return data
    end

    #
    # FUNCTION FOR SEARCH USER
    #

    # Retourne les infos de l'utilisateur recherchées au format JSON
    def getInfoAboutUser(userSearch)
        url = "https://api.github.com/users/" << userSearch
        info = formatJSON(url)

        return info
    end

    #
    # FUNCTIONS TO SEE THESE DEPOSITS
    #

    # Retourne les données de la liste de repos en JSON
    def getListOfRepo(userInfo)
        listOfReposUrl = userInfo["repos_url"]
        listOfRepos = formatJSON(listOfReposUrl)

        return listOfRepos
    end

    # Retourne les noms des repos de l'utilisateur
    def getNamesOfAllRepos(listOfRepos)
        namesOfAllRepos = []
        i = 0
        listOfRepos.each do |repo|
            repo.each do |nameOfKey, valueOfKey|
                if nameOfKey == "name"
                    namesOfAllRepos[i] = valueOfKey
                end
            end
            i += 1
        end

        return namesOfAllRepos
    end

    #
    # FUNCTIONS FOR DEPOSIT CONTRIBUTION STATISTICS
    #

    # Récupère les urls de contributeurs de chaque repos et convetie en JSON
    def getJsonOfContributorsForEachRepo(listOfRepos)
        jsonOfContributorsForEachRepo = []
        i = 0

        listOfRepos.each do |repos|
            repos.each do |nameOfKey, valueOfKey|
                if nameOfKey == "contributors_url"
                    jsonOfContributorsForEachRepo[i] = valueOfKey
                    jsonOfContributorsForEachRepo[i] = formatJSON(jsonOfContributorsForEachRepo[i])
                end
            end

            i += 1
        end

        return jsonOfContributorsForEachRepo
    end

    # Récupère le nombre de contributions de l'utilisateur par repo
    def getNumberOfContributionsForEachRepo(jsonOfContributorsForEachRepo, loginOfUser)
        numberOfContributionsForEachRepo = []
        i = 0

        jsonOfContributorsForEachRepo.each do |jsonOfContributorsForOneRepo|
            jsonOfContributorsForOneRepo.each do |user|
                if user["login"] == loginOfUser
                    numberOfContributionsForEachRepo[i] = user["contributions"]
                    i += 1
                end
            end
        end

        return numberOfContributionsForEachRepo
    end

    # Permets de comptabiliser tous les contributeurs de chaque repos
    def getTotalContributionForEachRepo(jsonOfContributorsForEachRepo)
        totalContributionForEachRepo = []
        i = 0

        jsonOfContributorsForEachRepo.each do |jsonOfContributorsForOneRepo|
            jsonOfContributorsForOneRepo.each do |user|
                if totalContributionForEachRepo[i] == nil
                    totalContributionForEachRepo[i] = 0
                end
                totalContributionForEachRepo[i] += user["contributions"]
            end
            i += 1
        end

        return totalContributionForEachRepo
    end

    # Récupère le pourcentage de contributions de l'utilisateur par repo
    def getPercentageOfContributionsForEachRepo(numberOfContributionsForEachRepo, totalContributionForEachRepo)
        percentageOfContributionsForEachRepo = []
        i = 0

        totalContributionForEachRepo.each do |numberOfContributions|
            percentageOfContributionsForEachRepo[i] = ((numberOfContributionsForEachRepo[i].to_i)/numberOfContributions.to_i) * 100
            i += 1
        end

        return percentageOfContributionsForEachRepo
    end

    #
    # FUNCTIONS TO SEE THE LANGUAGES
    #

    # Récupère l'URL de chaque repos qui permet d'accéder aux langages utilisés et transforme les données en JSON
    def getLanguagesForEachRepo(listOfRepos)
        languagesForEachRepo = []
        i = 0
        listOfRepos.each do |repo|
            repo.each do |nameOfKey, valueOfKey|
                if nameOfKey == "languages_url"
                    languagesForEachRepo[i] = valueOfKey
                    languagesForEachRepo[i] = formatJSON(languagesForEachRepo[i])
                end
            end
            i += 1
        end

        return languagesForEachRepo
    end

    #
    # FUNCTIONS FOR THE TOP 10 DEPOSIT CONTRIBUTORS
    #

    def getNumberOfContributionsForEachRepoByUser(jsonOfContributorsForEachRepo)
        numberOfContributionsForEachRepoByUser = []
        i = 0

        jsonOfContributorsForEachRepo.each do |jsonOfContributorsForOneRepo|
            numberOfContributionsForEachRepoByUser[i] = Hash.new
            jsonOfContributorsForOneRepo.each do |user|
                if !numberOfContributionsForEachRepoByUser[i][user["login"]].nil? && numberOfContributionsForEachRepoByUser[i].key?(user["login"])
                    numberOfContributionsForEachRepoByUser[i][user["login"]] += user["contributions"]
                else
                    numberOfContributionsForEachRepoByUser[i][user["login"]] = user["contributions"]
                end
            end

            i += 1
        end

        return numberOfContributionsForEachRepoByUser
    end

    # Permets de trier les contributeurs de chaque repos par ordre décroissant
    def sortContributorsByDESC(numberOfContributionsForEachRepoByUser)
        i = 0

        numberOfContributionsForEachRepoByUser.each do |numberOfContributionsForOneRepoByUser|
            numberOfContributionsForEachRepoByUser[i] = numberOfContributionsForOneRepoByUser.sort do |a, b|
                b[1] <=> a[1]
            end
            i += 1
        end

        return numberOfContributionsForEachRepoByUser
    end

    #
    # FUNCTIONS TO SEE THE TOP LANGUAGES
    #

    # Permets de comptabiliser tous les fichiers de tous les repos par langages
    def getTotalLanguagesForAllRepo(languagesForEachRepo)
        totalLanguagesForAllRepos = Hash.new

        languagesForEachRepo.each do |languagesForOneRepo|
            languagesForOneRepo.each do |nameOfKey, valueOfKey|
                if totalLanguagesForAllRepos.key?(nameOfKey)
                    totalLanguagesForAllRepos[nameOfKey] += valueOfKey
                else
                    totalLanguagesForAllRepos[nameOfKey] = valueOfKey
                end
            end
        end

        return totalLanguagesForAllRepos
    end

    # Permets de trier les langages utilisés de tous les repos par ordre décroissant
    def sortLanguagesByDESC(totalLanguagesForAllRepos)

        totalLanguagesForAllRepos = totalLanguagesForAllRepos.sort do |a, b|
            b[1] <=> a[1]
        end

        return totalLanguagesForAllRepos
    end

    #
    # FUNCTION TO STORE SEARCHES
    #

    # Stocke la recherche dans la BDD
    def storeSearchInDB(userResearch)
        Url.create(name: userResearch, user_id: session[:user_id])
    end
end