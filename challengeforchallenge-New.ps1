function get-PostTypeCount {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true,
            Position=0)]
        [validateset("Categories","Tags")]
        [string]$type
    )


    $baseURI = "https://ironscripter.us/wp-json/wp/v2/"+$type
    $output = Invoke-RestMethod -uri $baseURI
    
    if ($type = "Categories")
    {
        $output | select-object Name, Count
    }
    else
    {
        $output | Select-Object Name, Count | Where-Object {$_.name -eq "intermediate" -or $_.name -eq "beginner" -or $_.name -eq "advanced" }
    }
}

function get-Challenges {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false,
            Position=0)]
        [validaterange(1,50)]
        [int]$count = 5
    )

    $baseURI = "https://ironscripter.us/wp-json/wp/v2/"
    $category = Invoke-RestMethod -Uri $($baseURI+"categories")
    $alltag = Invoke-RestMethod -Uri $($baseURI+"tags")

    $challengeposts = Invoke-RestMethod -uri $((($category | Where-Object {$_.name -match "Challenge"})._links.'wp:post_type'.href)+'&per_page='+$($count))
    foreach ($c in $challengeposts) {
        $c | Select-Object @{ n= 'Title' ; e = {$c.title.rendered}}, 
            @{n='Date'; e= {$c.date}},
            @{n='Categories' ; e= {foreach ($cat in $c.categories)
                                {
                                    ($category| Where-Object {$_.id -match $cat}).name
                                }
                                }},
            @{n='Tags' ; e = {foreach ($t in $c.tags)
                                {
                                    ($alltag | Where-Object {$_.id -match $t}).name
                                }
                                }},
            @{n='Excerpt' ; e = {$c.excerpt.rendered -replace ‘<[^>]+>' -replace '&.*?;'}},
            @{n='URL' ; e = {$c.link}}
    }


}