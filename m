From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/4] sysfs: Implement sysfs manged shadow directory
	support.
Date: Mon, 23 Jul 2007 12:52:25 +0900
Message-ID: <46A425F9.1030008@gmail.com>
References: <1182446577.8138.29.camel@localhost>	<m1odj9dofp.fsf@ebiederm.dsl.xmission.com>	<20070621211637.GB10583@suse.de>	<m1fy4ldldm.fsf@ebiederm.dsl.xmission.com>	<20070622001328.GA14113@suse.de>	<m1tzt0cujt.fsf_-_@ebiederm.dsl.xmission.com>	<20070625212339.GA13398@kroah.com>	<m14pk13svx.fsf@ebiederm.dsl.xmission.com>	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>	<46A3B449.3090409@gmail.com>
	<20070722202508.GA18018@suse.de>
	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m17iosw075.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
> Further while there are a few little nits I think mostly Tejun is 
> mostly objecting to the fundamental complexity of the problem rather
> then to things that can be fixed by a cleaner implementation.

Oh well, I don't think so but I might be wrong.

> If it didn't take me a week every time I had to update this code
> after Tejun changes the locking rules in fs/sysfs/dir.c or if there
> was someone I could delegate the work of maintaining this code to
> I probably would not mind dropping the patches for a little bit.  As
> it stands I am having horrible nightmares about how the internals
> of sysfs will be completely different if you drop the last 3 patches
> by the time I come back and I will need to spend several more weeks
> just catching up.

Yeah, sysfs has gone through a lot of changes but I think most of
internal restructuring is complete now.  What's left is removing kobj
completely from sysfs internals and interface.

We kind of share the pain here although yours seems much worse than
mine.  Shadow directories have been major pain in the ass while
restructuring sysfs and I basically had to shoot in the dark because
there was no in-kernel user.  I guess the blame falls on the timing.

I'll give a shot at the no intermediate shadowed directory
implementation.  I think things will fit a lot easier that way but I
really dunno till I try.  I'll try to post prototype early.

As long as the current shadow implementation doesn't get into mainline.
 I'm okay with it staying in Greg's tree until this is resolved.

Thanks.

-- 
tejun
