From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [patch 1/4][resend] fuse-procfs: proxy proc files
Date: Mon, 28 Sep 2009 11:33:43 +0200
Message-ID: <ac1c4bf20909280233r5cd94343m30ac00c6ef9e1d10@mail.gmail.com>
References: <20090904162556.407556958@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20090904165149.491603361@mai-009101017029.toulouse-stg.fr.ibm.com>
	<ac1c4bf20909141338p3e13c1d6sc71899b7859bd963@mail.gmail.com>
	<4AAEB1FA.3070102@free.fr>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AAEB1FA.3070102-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Thank you Daniel.
I have a little problem with fuse and containers. Do I have to add the fuse
device to the container?
When I tried to mount procfs I received:

container2:/# ./procfs -odirect_io /proc/meminfo
fuse: device not found, try 'modprobe fuse' first

The fuse module was loaded on host. What I did wrong? I am asking because I
am working around user space scripts for managing lxc (written in bash,
init.d script, few lxc-create-* scripts based on distro, etc) and I would
like to add this development future to this scripts.
Right now I have few nice and good looking userspace scripts.
Would be great If I may do the deb and rpm package with lxc user scripts and
lxc-tools or add my scripts to lxc-tools tree.

More about that in this week in the different thread. Hope you will give me
the direction guys.


2009/9/14 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

> Krzysztof Taraszka wrote:
>
>> Hi Daniel,
>>
>> right now I do not have any new tasks so I can take a look your patches
>> and... they won't to apply (patches from 2 to 4).
>> Can you send me your current procfs.c single file with patches added?
>>
>> Thanks
>>
>>
> Sure, in attachment the procfs.tar.gz which is a directory containing the
> patches.
> Just untar and quilt push -a.
>
>  -- Daniel
>
>
>
