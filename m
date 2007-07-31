From: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow
	directory	support.
Date: Tue, 31 Jul 2007 17:15:34 +0900
Message-ID: <46AEEFA6.4000901@suse.de>
References: <1182446577.8138.29.camel@localhost>	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>	<20070622001328.GA14113@suse.de>	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>	<20070625212339.GA13398@kroah.com>	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>	<46A3B449.3090409@gmail.com>
	<20070722202508.GA18018@suse.de>	<m17iosw075.fsf@ebiederm.dsl.xmission.com>	<46A425F9.1030008@gmail.com>
	<46AD8E92.7080002@suse.de>	<46ADDC7F.1090306@sw.ru>
	<46ADE24E.8020502@suse.de>	<46ADEE35.8000109@sw.ru>
	<46ADF003.3010100@suse.de>	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com>
	<46AEAF79.6080404@suse.de>	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com>
	<46AEBA87.6000400@suse.de>
	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com>
	<46AEEF75.2030101@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46AEEF75.2030101-l3A5Bk7waGM@public.gmane.org>
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

Tejun Heo wrote:
> Eric W. Biederman wrote:
>> I think I have figured out how to safely remove s_dentry entirely from
>> sysfs_dirent and that winds up removing a lot of subtle and nasty locking.
>> I'm hoping to have a good patch series after another couple of hours of
>> work.
> 
> Great.  Yeah, open coding lookup seems much better idea than checking
> whether tree changed while sysfs_mutex was releated.

s/related/released/

-- 
tejun
