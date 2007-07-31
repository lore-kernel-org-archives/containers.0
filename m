From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 0/14] sysfs cleanups
Date: Tue, 31 Jul 2007 04:16:25 -0600
Message-ID: <m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost>
	<20070625212339.GA13398@kroah.com>
	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>
	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>
	<46A3B449.3090409@gmail.com> <20070722202508.GA18018@suse.de>
	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
	<46A425F9.1030008@gmail.com> <46AD8E92.7080002@suse.de>
	<46ADDC7F.1090306@sw.ru> <46ADE24E.8020502@suse.de>
	<46ADEE35.8000109@sw.ru> <46ADF003.3010100@suse.de>
	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com> <46AEAF79.6080404@suse.de>
	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com> <46AEBA87.6000400@suse.de>
	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com> <46AEEF75.2030101@suse.de>
	<46AEEFA6.4000901@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46AEEFA6.4000901-l3A5Bk7waGM@public.gmane.org> (Tejun Heo's message of "Tue, 31 Jul
	2007 17:15:34 +0900")
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


Ok.  I don't know how alert I am at the moment (it's way past my bed
time) but I have been digging in and cleaning up sysfs.  I'm not quite
to the point of supporting multiple mounts and shadow directories
again but the locking is looking much simpler and cleaner.  So with a
little luck this will be a better base to build on.

If something looks horrible please holler.

Eric
