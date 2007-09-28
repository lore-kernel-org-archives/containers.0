From: Mark Nelson <markn-8fk3Idey6ehBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Fri, 28 Sep 2007 10:53:58 +1000
Message-ID: <46FC50A6.1040302@au1.ibm.com>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>	<46FB6F1E.8070105@fr.ibm.com>	<m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>	<20070927.124552.69400277.davem@davemloft.net>
	<m18x6rhfy0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m18x6rhfy0.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> 
>> Eric, pick an appropriate new non-conflicting number NOW.
> 
> Done.  My apologies for the confusion.  I thought the
> way Cedric and the IBM guys were testing someone would have
> shouted at me long before now.

Sorry Eric, that was me that should have been shouting at you. It got lost because I modified the patches I extracted from your git tree so they would apply to -mm, leaving me thinking there were no extra patches...

Further apologies for dropping the ball - it won't happen again.


Mark.
> 
>> This adds unnecessary extra work for Andrew Morton, which he has
>> enough of already.
> 
> Cedric made a good point that we will have conflicts of code
> being added to the same place in nsproxy.c and the like.  So
> I copied Andrew to give him a heads up.
> 
> I will gladly do what I can, to help.  Working against 3 trees
> development at the moment is a bit of a development challenge.
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
