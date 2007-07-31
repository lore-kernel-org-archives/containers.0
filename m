From: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 03/14] sysfs: Move all of inode initialization into
	sysfs_init_inode
Date: Tue, 31 Jul 2007 19:43:40 +0900
Message-ID: <46AF125C.80309@suse.de>
References: <1182446577.8138.29.camel@localhost>
	<46A3B449.3090409@gmail.com>	<20070722202508.GA18018@suse.de>	<m17iosw075.fsf@ebiederm.dsl.xmission.com>	<46A425F9.1030008@gmail.com>
	<46AD8E92.7080002@suse.de>	<46ADDC7F.1090306@sw.ru>
	<46ADE24E.8020502@suse.de>	<46ADEE35.8000109@sw.ru>
	<46ADF003.3010100@suse.de>	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com>
	<46AEAF79.6080404@suse.de>	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com>
	<46AEBA87.6000400@suse.de>	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com>
	<46AEEF75.2030101@suse.de>	<46AEEFA6.4000901@suse.de>	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1r6moswhr.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Besides being a good general cleanup the ultimate effect
> of this patch is that sysfs_get_inode now gives you a
> usable inode that doesn't need any further initialization
> to be useful.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

I generally like it.  The only nits are that I think we're better off
keeping the function in fs/sysfs/dir.c as all the interesting parts are
there anyway and sysfs_instantiate() can just die.  The function is just
a remnant of days where inode initialization was scattered all over the
place.

Thanks.

-- 
tejun
