From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Fri, 28 Sep 2007 11:12:13 +0200
Message-ID: <46FCC56D.9050600@fr.ibm.com>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com> <46FB6F1E.8070105@fr.ibm.com> <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com> <20070927.124552.69400277.davem@davemloft.net> <m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org, netdev@vger.kernel.org, akpm@linux-foundation.org
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> David Miller <davem@davemloft.net> writes:
> 
>> Eric, pick an appropriate new non-conflicting number NOW.
> 
> Done.  My apologies for the confusion.  I thought the
> way Cedric and the IBM guys were testing someone would have
> shouted at me long before now.
>
>> This adds unnecessary extra work for Andrew Morton, which he has
>> enough of already.
> 
> Cedric made a good point that we will have conflicts of code
> being added to the same place in nsproxy.c and the like.  So
> I copied Andrew to give him a heads up.

here's a suggestion,

we could keep the net namespace unshare patch out of david's tree,
let andrew merge and release a new -mm and, then, send the net namespace 
unshare patch to andrew. that should keep nsproxy out of the andrew's 
merge challenge. But david's tree will miss the unshare part for a while.

As for the clone flags, the values *must not* conflict but the patches 
probably will.

C.

> I will gladly do what I can, to help.  Working against 3 trees
> development at the moment is a bit of a development challenge.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

