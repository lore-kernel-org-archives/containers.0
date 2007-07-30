From: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow
	directory	support.
Date: Mon, 30 Jul 2007 22:06:22 +0900
Message-ID: <46ADE24E.8020502@suse.de>
References: <1182446577.8138.29.camel@localhost>	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>	<20070621211637.GB10583@suse.de>	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>	<20070622001328.GA14113@suse.de>	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>	<20070625212339.GA13398@kroah.com>	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>	<46A3B449.3090409@gmail.com>	<20070722202508.GA18018@suse.de>	<m17iosw075.fsf@ebiederm.dsl.xmission.com>	<46A425F9.1030008@gmail.com>
	<46AD8E92.7080002@suse.de> <46ADDC7F.1090306@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46ADDC7F.1090306-3ImXcnM4P+0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kirill Korotaev <dev-3ImXcnM4P+0@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Kirill.

Kirill Korotaev wrote:
> Imho then OpenOVZ approach with multiple sysfs trees is better.
> it allows to use cached dentries with moultiple sysfs mounts
> each having different view.
> It also allows to hide hw-related entries and events from the containers
> and has quite little modifications in the code.

I thought something like supermount plus some twists or fuse based sysfs
proxy would fit better.  Dunno whether or how uevent and polling stuff
can work that way tho.  Note that sysfs no longer keeps dentries and
inodes pinned.  It might make the shared dentry stuff harder.

Thanks.

-- 
tejun
