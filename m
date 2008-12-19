From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Where can I play the memory control (with -mm)
Date: Fri, 19 Dec 2008 11:31:42 +0100
Message-ID: <494B780E.70904@free.fr>
References: <8f34198c0812171929i6e26fdb4uc5862d102bb4fc41@mail.gmail.com>	<20081218124747.616B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<8f34198c0812182216x21e5ac4ci8a44e366a39f658b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Ian jonhson wrote:
> hmm...  so many patches need to be patched in current kernel mainstream?
>
> I am now using the kernel version:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/daveh/linux-2.6-lxc.git
>
> It seems the linux-2.6-lxc has not been updated for a couple of months
> because I got "Already up-to-date" after running "git-pull". So, I am
> wondering how many patches need to be patched in my kernel? all?
> Is there any kernel that has been patched for experiment?
>
>
>   
>> mmotm (mm on the moment == latest -mm tree) is here :)
>>
>> http://userweb.kernel.org/~akpm/mmotm/
>>     

Perhaps you can try the net-next-2.6 kernel version which is the future 
2.6.29.

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

AFAICS, it should have everything you need in terms of isolation and 
control group.

 -- Daniel
