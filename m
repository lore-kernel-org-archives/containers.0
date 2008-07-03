From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 06/11] sysfs: Implement sysfs tagged directory support.
Date: Thu, 03 Jul 2008 12:18:45 +0900
Message-ID: <486C4515.1070007@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>	<20080618170731.002784342@theryb.frec.bull.fr>	<485F04E1.70204@gmail.com>
	<m1y74svtff.fsf@frodo.ebiederm.org>	<486706C9.9040303@gmail.com>
	<m18wwmsqdv.fsf@frodo.ebiederm.org>	<4869D314.5030403@gmail.com>
	<m1ej6enep7.fsf@frodo.ebiederm.org>	<486A0751.9080602@gmail.com>
	<m1wsk5hjm0.fsf@frodo.ebiederm.org>	<486AF4FA.8020805@gmail.com>
	<m1ej6d9c2r.fsf@frodo.ebiederm.org>	<486B060C.7030607@gmail.com>
	<m14p78s02q.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m14p78s02q.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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
Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Eric.

Eric W. Biederman wrote:
>> If
>> changing the default function is too much of a hassle (and I'm sure it
>> would be), just add an extended version which takes @tag.  The current
>> implementation feels like it tried too hard to not add intermediate
>> interfaces and ended up shooting outside from the innermost layer.
> 
> It tried for something that was simple to use and that worked.
> 
> Also the way things work.  I have to use all of the intermediate layers
> and their calls to various functions.  So just passing a parameter through
> doesn't work to well.

There is rather large possibility that I'm just being dumb here
especially because I haven't reviewed the users of this facility, so all
the comments I'm making are from the POV of interfaces of sysfs and the
related layers.  I think I've made my concerns clear by now.  If you
still think the callbacks are the best way to go, please try to
enlighten me.  I really don't wanna be stopping something which is
better from ignorance.  Just give me some concrete examples or point me
to codes which show how and why the current interface is the best for
the users and switching isn't a good idea.

> It looks to me like the clean solution is move kobject_tag into
> kobj_type, and have it call some higher level function.
> 
> We also need to remove the maintenance disaster that is
> kobject_set_name from sysfs_rename_dir.  And push it into
> kobject_rename instead.  The error handling is harder in
> that case but otherwise we should be in good shape.

Heh... I personally think kobject layer as a whole should just be hidden
under the cabinet of device driver model but I'm having difficult time
convincing other people of it.  Anyways, fully agree the interaction
between kobject and sysfs is ugly at a lot of places.

>>> On the other side I can't pass a tag through from the device layer to
>>> the kobject layer.  It isn't a concept the kobject layer supports.
>> I think it's best to make kobject layer support it.
> 
> Assuming Greg will accept it when he sees reasonable patches.

Greg says he would.  :-)

Thanks a lot for your patience.

-- 
tejun
