From: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 11/14] sysfs: Remove s_dentry form sysfs_dirent.
Date: Tue, 31 Jul 2007 20:18:22 +0900
Message-ID: <46AF1A7E.2020703@suse.de>
References: <1182446577.8138.29.camel@localhost>
	<46ADF003.3010100@suse.de>	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com>
	<46AEAF79.6080404@suse.de>	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com>
	<46AEBA87.6000400@suse.de>	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com>
	<46AEEF75.2030101@suse.de>	<46AEEFA6.4000901@suse.de>	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>	<m1abtcsw8w.fsf_-_@ebiederm.dsl.xmission.com>	<m16440sw6d.fsf_-_@ebiederm.dsl.xmission.com>	<m11weosvzz.fsf_-_@ebiederm.dsl.xmission.com>	<m1wswgrh8x.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl74rh6e.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1sl74rh6e.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
> After the last round of refactoring nothing is really using
> using s_dirent so remove it.  Which makes the code easier to work
> with and follow.  And with a little luck makes it easier to
> support multiple dentry trees for sysfs.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Hooray, Acked-by: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

-- 
tejun
