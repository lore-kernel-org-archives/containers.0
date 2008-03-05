From: Xpl++ <xpl-d4um4pvOpxY@public.gmane.org>
Subject: Re: [RFC] libcg: design and plans
Date: Wed, 05 Mar 2008 21:36:20 +0200
Message-ID: <47CEF634.1070506__39718.822312034$1204745872$gmane$org@amln.net>
References: <20080304152341.GB5659@linux.vnet.ibm.com>
	<47CD83C7.4020206@amln.net>
	<20080305052631.GA26361@linux.vnet.ibm.com>
	<47CE8A67.3050109@amln.net>
	<20080305155310.GA5349@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080305155310.GA5349-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: fedora-devel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, opensuse-packaging-stAJ6ESoqRxg9hUCZPvPmw@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Sudhir Kumar <skumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Dhaval,

Dhaval Giani ??????:
>> Imagine having a shared/joint household savings account with your wife, and 
>> taking money from it without your wife knowing and vice versa .. then at 
>> some point when you thought that you have some $5K to buy the new super 
>> duper laptop you dreamt about your entire life - surprise - no enough 
>> resources :)
>> This is somewhat the equivalent of multiple independent resourse managers 
>> :) It won't end well :)
>> Should they be expected to be adequate in doing their job, they cannot be 
>> independent since they manage a shared resource.
>>
>>     
>
> I don't quite agree with your analogy here. The point here is that each
> resource manager operates in its own area, and has already been assigned
> some resources which it cannot change. Its more like you can take $x at
> the most from the account and your wife $y with x+y<=total money.
>   
Ok .. so imagine that your kid got sick and you need more than $x, while 
you wife does not need any money at that particular moment?
Would you:

a) take a loan (buy more hardware/resources, just because we can), 
despite the fact you already have them in you account, and since we're 
talking about your child it's in the interest of both you and your wife 
(tha family, 'the whole' so to speak) to cure the illness

b) notify your wife there is an emergency and you will need some extra 
money which has to come from her $y quota, take the money, make the kid 
happy, and just continue business as usual? (that is - being smart and 
dynamic in resource allocation)

With the proposed libcg, answer a) seems to be the only option .. and my 
company is not like M$ so I don't have extra resources to waste just 
because I was told resources cannot be managed dynamicaly :)
Why would one need to manage node resources dynamicaly: in our real-life 
production system we have to manage resources dynamicaly, because any 
other solution would require at least twice as much hardware, which will 
also inevitably lead to a necessity to hire more qualified admins, which 
is once again not so wise for small/medium business .. and not to 
mention the extra CO2 caused by the few more dozens of servers :)

Regards,
Peter.
