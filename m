From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH] rlimit: Account nproc per-usernamespace/per-user
Date: Mon, 7 Nov 2016 10:56:09 -0600
Message-ID: <20161107165609.GA31448@mail.hallyn.com>
References: <1477485627-16177-1-git-send-email-kernel@kyup.com>
	<20161026172541.GA12228@mail.hallyn.com>
	<0e584ff0-3622-231c-5da2-960cbee698c1@kyup.com>
	<20161027143715.GA23294@mail.hallyn.com>
	<69716b99-dbd3-e4e3-f650-908474cb0b14@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <69716b99-dbd3-e4e3-f650-908474cb0b14-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nikolay Borisov (kernel-6AxghH7DbtA@public.gmane.org):
> 
> 
> On 10/27/2016 05:37 PM, Serge E. Hallyn wrote:
> > Quoting Nikolay Borisov (kernel-6AxghH7DbtA@public.gmane.org):
> >>
> >>
> >> On 10/26/2016 08:25 PM, Serge E. Hallyn wrote:
> >>> On Wed, Oct 26, 2016 at 03:40:27PM +0300, Nikolay Borisov wrote:
> >>>> There are container setups which map the same kuids to
> >>>> different containers. In such situation what will happen is
> >>>> that same uid's in different containers will map to the same
> >>>> underlying user on the matchine (e.g. same struct user). One
> >>>> implication of this is that the number of processes for that
> >>>> particular user are going to be shared among all the same uids
> >>>> in the container. This is problematic, as it means a user in
> >>>> containerA can potentially exhaust the process limit such that
> >>>> a user in containerB cannot spawn any processes.
> >>>
> >>> Hi - thanks for the description.  Based on that, though, I worry
> >>> that it is a feature we do not want.  Nothing explicitly prohibits
> >>> sharing kuids in different containers, but it is is sharing.  If
> >>> you want greater isolation between two containers, you must not share
> >>> any kuids.
> >>>
> >>> I'm not saying nack, but i am saying it seems a misguided feature
> >>> which could lead people to think sharing uids is safer than it is.
> >>
> >> I agree that in order for this to be considered "secure" it relies on
> >> the assumption that there is no leakage between containers. However,
> >> there are currently setups which rely on this behavior for whatever
> >> (mis)guided reasons. Furthermore the current design of namespaces
> >> doesn't do anything to prevent such uses. Given this I don't think it be
> >> fair to completely disregard them, hence the patch.
> > 
> > I somehow had missed the fact that (if I read below correctly) you
> > are actually solving the problem for RLIMIT_NPROC?  That's worthwhile
> > then.  I thought the ucounts checks were independent and RLIMIT_NPROC
> > failures were still going to mysteriously plague sibling containers.
> > 
> > I do still worry about the performance impact of adding the get_ucounts()
> > in those hot paths below.  Have you done any perf measurements?
> > 
> 
> Finally managed to get around doing some benchmarking. I performed tests on 
> 4.9-rc1 with and without my patch. On every kernel I performed 3 tests: 
>  - 5 stress-ng instances, doing 250k forks in the init_user_ns
>  - 5 stress-ng instances, doing 250k forks in child of init_user_ns (nest factor of 1)
>  - 5 stress-ng instances, doing 250k forks in child of init_user_ns (nest factor of 5). 
> 
> I ran every experiment 5 times and got the stdev and the average values. Here is how I invoked stress-ng : 
> 
> for i in {1..5}; do time /home/projects/kernel-testing/stress-ng/stress-ng -f 5 --fork-ops 250000 ; done
> 
> And every unsharing of a namespace was performed by means of "unshare -r"
> 
> The results are as follows: 
> 
> 		Stock 4.9-rc1			Patched 4.9-rc1-nproc			
> 		Real	STDEV	Sys	STDEV	Real	STDEV	Sys	STDEV
> init_user_ns	28.872s	0.167	49.714	0.51	28.386	0.168	49.217	0.899
> depth of 1 	27.808	0.448	48.869	0.275	28.303	0.225	50.44	0.174
> depth of 5	27.614	0.226	49.336	0.43	28.22	0.737	49.72	0.934
> 
> The results are almost identical with only 3% diffrence in the sys time of 1 child ns, 
> and 1% with 5 ns child. I think the results are rather noisy. While the tests were 
> running I also observed the % for (dec|inc)_ulimit and they were around 0,06%. Very 
> negligible. I think on the performance side of things this should be good.  

Awesome, thanks for that.
