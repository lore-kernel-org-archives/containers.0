From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow
	directory	support.
Date: Mon, 30 Jul 2007 09:51:28 -0600
Message-ID: <m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost>
	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>
	<20070621211637.GB10583@suse.de>
	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>
	<20070622001328.GA14113@suse.de>
	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>
	<20070625212339.GA13398@kroah.com>
	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>
	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>
	<46A3B449.3090409@gmail.com> <20070722202508.GA18018@suse.de>
	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
	<46A425F9.1030008@gmail.com> <46AD8E92.7080002@suse.de>
	<46ADDC7F.1090306@sw.ru> <46ADE24E.8020502@suse.de>
	<46ADEE35.8000109@sw.ru> <46ADF003.3010100@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46ADF003.3010100-l3A5Bk7waGM@public.gmane.org> (Tejun Heo's message of "Mon, 30 Jul
	2007 23:04:51 +0900")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org> writes:

> Kirill Korotaev wrote:
>> Tejun Heo wrote:
>>> I thought something like supermount plus some twists or fuse based sysfs
>>> proxy would fit better.  Dunno whether or how uevent and polling stuff
>>> can work that way tho.  Note that sysfs no longer keeps dentries and
>>> inodes pinned.  It might make the shared dentry stuff harder.
>> 
>> We simply don't share sysfs dentries/inodes between containers.
>> It's not that frequently used time critical fs to be super-optimized... :)
>
> OIC, dentries and inodes are not shared.  Good then.  Agreed that sysfs
> doesn't need to be super-optimized as long as big machines aren't
> penalized too much (both memory and cpu cycle wise).
>
>> I don't like the idea with fuse, since sysfs exports kernel-related stuff,
>> so doing it via user-space would be pain.
>
> Yeah, it would be cumbersome to setup but it's also fast and easy to toy
> with for prototypes at least.

How close are we to the point where we can get mount sysfs multiple
times and get multiple dentry trees with different super blocks?

That really does sound like the right way to go.  Especially as it
simplifies the monitoring of containers.  If you want to watch what
the view looks like in some container your bind mount his sysfs and
look at that.

If we can do that the dcache side at least will be beautiful.  And
with a little care we may be able to reduce the work to a special case
in lookup, some extra handling to mark directories as belonging only
to a certain mount of sysfs.

If we can find something that is stupid and simple I'm all for that.

To reach the no-kobj utopia we may also need a special device_migrate
that is a super set of device_rename (because sometimes we need to
rename devices when we move them between namespaces).

So are we close to having a sysfs that we can have multiple super
blocks for?

I'm on a sysctl tangent, but I should be able to look at that in
just a little bit.

Eric
