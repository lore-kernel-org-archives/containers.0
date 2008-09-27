From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Re: [PATCH 08/10] Define get_sb_ref()
Date: Fri, 26 Sep 2008 17:47:27 -0700
Message-ID: <20080927004727.GA2161@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175308.GI17350@us.ibm.com>
	<1222286127.15523.66.camel@nimitz>
	<20080926212115.GD31505@us.ibm.com>
	<1222464662.25451.23.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1222464662.25451.23.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| On Fri, 2008-09-26 at 14:21 -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
| > Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| > | On Fri, 2008-09-12 at 10:53 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| > | > + *     But for single-mount semantics, devpts cannot use get_sb_single(),
| > | > + *     because get_sb_single()/sget() find and use the super-block from
| > | > + *     the most recent mount of devpts. But that recent mount may be a
| > | > + *     'newinstance' mount and get_sb_single() would pick the newinstance
| > | > + *     super-block instead of the initial super-block.
| > | 
| > | Can't you just override the test() function to get what you want here?
| > 
| > get_sb_single() does not take a test() parameter and so I would still
| > need a get_sb_ref() or get_sb_special() interface right ? 
| > 
| > This special interface could call sget() with a custom-test function,
| > to get the super-block.  But in case of devpts, we already have the
| > super-block. So we don't need to call sget(). We just need get a reference
| > and remount.
| 
| Well, you shouldn't be using get_sb_single() at all any more, right?

You mean define something like get_sb_multi_mode() and define a  new
test function ? I can try that.

| 
| At this point, you're doing something super-specialized for devpts.  So,
| why do this in super.c.  Just put it in place of devpts_get_sb()'s
| current contents.

grab_super() is static. I have to either externalize it or define the
new interface in fs/super.c.  I am not sure if mqueue ns or others have
similar semantics and if so, defining interface in fs/super.c has a better
chance of being found/generalized when there is another user.

| 
| For me get_sb_ref() is a super-confusing name, especially when mixed
| with all the other sb functions.  WTF is get_sb() doing if there's a
| get_sb_ref()?

I agree its not a great name. The 'get_sb's do several things some in
private interfaces, and I needed only a subset of them.

Do you have any preference over get_sb_multi_mode() over exporting 
grab_super() and moving the pts-specific stuff to into devpts/inode.c
