@{
    Rules = @{
        PSAvoidUsingCmdletAliases = @{
            AllowList = @('foreach', 'select', 'sort', 'where')
        }
        PSAvoidUsingPositionalParameters = @{
            Enable = $false
        }
    }
}
