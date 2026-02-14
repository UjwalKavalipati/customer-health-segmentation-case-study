# customer-health-segmentation-case-study
CS Operations System Design - Signal-based customer  health segmentation model for SaaS company scaling  customer success operations

# Customer Health Segmentation System - Case Study

## Overview
Designed a signal-based customer health segmentation system 
for a fictitious scale-up with 850 customers and a 2-person 
CS team. The solution enables proactive customer success 
operations without requiring a traditional 0-100 health score.

## Business Problem
- 850 active customers (real estate agencies)
- 2-person CS team operating reactively (only Day 1/Day 30 calls)
- No systematic way to identify churn risk, expansion 
  opportunities, or onboarding issues
- Data sources: HubSpot (CRM), Matomo (product analytics), 
  Stripe (billing)
- No data warehouse (building one) - manual data joins required

## Solution: 5-Segment Model

Instead of a traditional health score, I designed a 
signal-based segmentation system that tells the CS team 
WHO to contact and WHY:

### 1. Revenue at Risk (Highest Priority)
**Criteria:**
- Days to renewal ≤ 60 AND
- (Payment failed OR Support tickets ≥3 OR Inactive 14+ days)

**CS Action:** Call within 24 hours

### 2. Engagement Drop (Early Warning)
**Criteria:**
- Inactive 14+ days AND
- Usage level = Low (<8 logins/month) AND
- Renewal > 60 days

**CS Action:** Re-engagement email

### 3. Expansion Opportunity
**Criteria:**
- High usage (15+ logins/month) AND
- Features used ≥ 3 AND
- Support tickets ≤ 1 AND
- On Basic/Standard plan

**CS Action:** Upsell conversation

### 4. Onboarding Stuck
**Criteria:**
- Account age ≤ 30 days AND
- (Inactive 7+ days OR <2 features used)

**CS Action:** Proactive training

### 5. Healthy & Stable
**Criteria:**
- Medium/High usage (≥8 logins/month) AND
- Payment current AND
- Renewal > 60 days

**CS Action:** Quarterly check-in only

## Technical Implementation

### Data Sources
- **HubSpot (CRM):** Contract dates, support tickets, MRR
- **Stripe (Billing):** Payment status (via native integration)
- **Matomo (Product Analytics):** Login data, feature usage 
  (synced via weekly CSV import)

### Data Flow
1. matomo → Weekly CSV export → Import to HubSpot
2. HubSpot calculates derived fields (days since login, 
   days to renewal, usage level)
3. Segment assignment runs daily at 9am
4. Tasks auto-created for CS team based on segment

### Sample SQL Query
See `sql_examples.sql` for implementation of segment logic.

## CS Workflow Design

**Daily Process:**
1. 9am: CS team opens HubSpot, sees prioritized task queue
2. Click task → See customer context (MRR, renewal date, 
   reason for flag)
3. Make call/send email
4. Log outcome (30 seconds - dropdowns)
5. System auto-updates segment based on outcome

**Outcome Logging:**
- What happened? (Reached/Voicemail/Email)
- What was issue? (Payment/Usage/Technical)
- Action taken? (Resolved/Follow-up/Lost)

**System Updates:**
- If "Issue Resolved" → Update to "Healthy & Stable"
- If "Follow-up needed" → Create task for future date
- If "Customer cancels" → Update status, stop tasks

## Design Rationale

**Why segments instead of numeric score?**
- Works with incomplete data (resilient to matomo gaps)
- Immediately actionable (CS knows exactly what to do)
- No arbitrary weight justification needed
- Easier for 2-person team to adopt

**Key Design Choice:**
After follow-up scheduled, monitoring continues to catch 
escalations (payment failures, ticket spikes) before 
follow-up date. Small customer base (850) makes duplicate 
tasks manageable; risk of missing churn > risk of 
duplication.



## Tools & Technologies
- **SQL** (PostgreSQL) - Data querying and segment logic
- **HubSpot** - CRM, workflow automation, task management
- **Matomo** - Product analytics (data source)
- **Stripe** - Payment data (via HubSpot integration)
- **Power BI** - Segment performance dashboards (mentioned)

## Skills Demonstrated
- Customer segmentation strategy
- SQL (joins, CTEs, window functions, CASE logic)
- Workflow design and automation
- Data quality considerations (handling missing data)
- Stakeholder communication (CS team adoption)
- Systems thinking (iterative, phased implementation)

## Files in This Repository
- `README.md` - This overview
- `presentation.pdf` - Full case study presentation
- `sql_examples.sql` - Sample SQL for segment identification

---

**Note:** The approach and technical design 
are applicable to any B2B SaaS customer success operation.
