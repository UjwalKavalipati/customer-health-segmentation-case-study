-- Revenue at Risk Segment Identification
-- Finds customers approaching renewal with problem signals

SELECT 
    c.customer_id,
    c.customer_first_name, 
    c.customer_last_name,
    c.customer_phone,
    c.customer_email,
    c.renewal_date,
    p.last_login_date,
    
    -- Calculated fields for urgency and engagement
    DATEDIFF(day, CURRENT_DATE, c.renewal_date) AS days_to_renewal,
    DATEDIFF(day, p.last_login_date, CURRENT_DATE) AS days_since_login

FROM hubspot_customer_accounts c

LEFT JOIN product_usage p  
    ON c.customer_id = p.customer_id

WHERE 
    -- Must be active customer
    c.subscription_status = 'active' 
    
    -- Renewal within 60 days
    AND DATEDIFF(day, CURRENT_DATE, c.renewal_date) BETWEEN 0 AND 60
    
    -- At least one problem signal: inactive for 14+ days
    AND DATEDIFF(day, p.last_login_date, CURRENT_DATE) >= 14

ORDER BY days_to_renewal ASC;

-- Note: In production, this would also check payment_status 
-- and support_ticket_count using additional LEFT JOINs
```


-- At risk customers long query
-- Find at-risk customers approaching renewal with low engagement
SELECT 
    c.customer_id,
    c.company_name,
    c.account_owner,  -- CS rep assigned
    c.subscription_status,
    c.contract_end_date,
    DATEDIFF(day, CURRENT_DATE, c.contract_end_date) AS days_to_renewal,
    c.monthly_recurring_revenue AS mrr,
    
    -- Login activity
    MAX(l.login_date) AS last_login_date,
    DATEDIFF(day, MAX(l.login_date), CURRENT_DATE) AS days_since_last_login,
    
    -- Feature usage
    COUNT(DISTINCT f.feature_name) AS features_used_last_30d,
    
    -- Support context
    COUNT(t.ticket_id) AS support_tickets_last_30d

FROM customers c

-- Join login data from Matomo
LEFT JOIN login_events l 
    ON c.customer_id = l.customer_id 
    AND l.login_date >= CURRENT_DATE - INTERVAL '30 days'

-- Join feature usage from Matomo
LEFT JOIN feature_usage f 
    ON c.customer_id = f.customer_id 
    AND f.event_date >= CURRENT_DATE - INTERVAL '30 days'

-- Join support tickets from HubSpot
LEFT JOIN support_tickets t 
    ON c.customer_id = t.customer_id 
    AND t.created_date >= CURRENT_DATE - INTERVAL '30 days'

WHERE 
    -- Active subscription
    c.subscription_status = 'active'
    
    -- Within 60 days of renewal
    AND c.contract_end_date <= CURRENT_DATE + INTERVAL '60 days'
    AND c.contract_end_date > CURRENT_DATE
    
    -- Haven't logged in for 14+ days
    AND (
        MAX(l.login_date) IS NULL  -- Never logged in
        OR DATEDIFF(day, MAX(l.login_date), CURRENT_DATE) >= 14
    )

GROUP BY 
    c.customer_id,
    c.company_name,
    c.account_owner,
    c.subscription_status,
    c.contract_end_date,
    c.monthly_recurring_revenue

ORDER BY 
    c.monthly_recurring_revenue DESC,  -- Prioritize high-value customers
    days_to_renewal ASC;  -- Then by urgency
