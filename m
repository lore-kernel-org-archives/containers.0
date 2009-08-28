From: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [Test Result] I/O bandwidth Control by dm-ioband - partition-based
	environment
Date: Fri, 28 Aug 2009 11:58:57 -0400
Message-ID: <4A97FEC1.1010500@ds.jp.nec.com>
References: <2891419e0908261846v4fa19791q4552975f10dd64e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2891419e0908261846v4fa19791q4552975f10dd64e5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: ioband-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, corsetproject-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Id: containers.vger.kernel.org

Hello Dong-Jae,

Dong-Jae Kang wrote, on 08/26/2009 09:46 PM:
> Hi Ryo
>
> I attached new test result file(ioband-partition-based-evaluation.xls)in
> this mail.
> In this time, it is not virtualization environment.
> I evaluated partition-based use cases before I do it in vitualization
> environment.
> because I think the two cases are smilar each other.
>
> The detailed information about the evaluation can be referred in attached
> file.
>
> If you have any questions or comments after examine it,
> please give me your opinion.
>
> Thank you.

Good work.
Please let me ask silly questions.

(1) About what "target" means
I guess "device" means writing to device files directly
(--filename=/dev/mapper/ioband1)
and "directory" means mounting these device files and writing to some directory
on the filesystem
(--filename=/mnt/ioband1/test.dat, I'm assuming mount /dev/mapper/ioband1 on
/mnt/ioband1),
am I wright?

(2) Conditions  in RDF sheet
Conditions in sheet "RDF" and "RBF" are same but results are slightly different.
Should "Mode" in RDF sheet be "Direct"?


Regards,
Muuhh

-- 
IKEDA, Munehiro
   NEC Corporation of America
     m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
