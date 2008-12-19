From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Where can I play the memory control (with -mm)
Date: Fri, 19 Dec 2008 12:39:41 +0530
Message-ID: <20081219070941.GK26572@balbir.in.ibm.com>
References: <8f34198c0812171929i6e26fdb4uc5862d102bb4fc41@mail.gmail.com>
	<20081218124747.616B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<8f34198c0812182216x21e5ac4ci8a44e366a39f658b@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8f34198c0812182216x21e5ac4ci8a44e366a39f658b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

* Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2008-12-19 14:16:50]:

> hmm...  so many patches need to be patched in current kernel mainstream?
>

The memory controller is in mainline, unless you want all the latest
features, you should just be able to get it working from mainline
 
> I am now using the kernel version:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git
> 
> It seems the linux-2.6-lxc has not been updated for a couple of months
> because I got "Already up-to-date" after running "git-pull". So, I am
> wondering how many patches need to be patched in my kernel? all?
> Is there any kernel that has been patched for experiment?
>

What do you want to experiment with? You might want to look at the lxc
status to see what is in mainline already.
 
> 
> > mmotm (mm on the moment == latest -mm tree) is here :)
> >
> > http://userweb.kernel.org/~akpm/mmotm/
> >
> >
> 
> Thanks again,
> 
> Ian
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

-- 
	Balbir
