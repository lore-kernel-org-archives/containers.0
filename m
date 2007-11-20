From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] capabilities: introduce per-process capability
	bounding set (v8)
Date: Tue, 20 Nov 2007 12:32:42 -0600
Message-ID: <20071120183242.GA11967@sergelap.austin.ibm.com>
References: <20071119212519.GA23178@sergelap.austin.ibm.com>
	<47425727.10702@kernel.org>
	<20071120181452.GA10765@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071120181452.GA10765-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, KaiGai Kohei <kaigai-vifXKdUkV5/bmG5+kqVDhQ@public.gmane.org>, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Andrew Morgan (morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> > 
> > Serge E. Hallyn wrote:
> > > Andrew, this version follows all of your suggestions.  Definately nicer
> > > userspace interface.  thanks
> > [...]
> > > 
> > >  /* Allow ioperm/iopl access */
> > > @@ -314,6 +314,10 @@ typedef struct kernel_cap_struct {
> > >  
> > >  #define CAP_SETFCAP	     31
> > >  
> > > +#define CAP_NUM_CAPS         32
> > > +
> > > +#define cap_valid(x) ((x) >= 0 && (x) < CAP_NUM_CAPS)
> > > +
> > 
> > Could you change the name of CAP_NUM_CAPS? There is some libcap building
> > code that does the following to automatically build the "cap_*" names
> > for libcap, and this new define above messes that up! :-(
> > 
> > sed -ne '/^#define[ \t]CAP[_A-Z]\+[ \t]\+[0-9]\+/{s/^#define \([^
> > \t]*\)[ \t]*\([^ \t]*\)/  \{ \2, \"\1\"
> > \},/;y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;p;}' <
> > $(KERNEL_HEADERS)/linux/capability.h | fgrep -v 0x > cap_names.sed
> > 
> > Something like:
> > 
> >   #define CAP_NUM_CAPS (CAP_SETFCAP+1)
> > 
> > will save me some hassle. :-)
> 
> Gotcha.  Will change that.
> 
> I worry that what you have is just a *touch* too busy so whoever adds
> capability #32 might forget to update CAP_NUM_CAPS, but it looks like
> 
> #define CAP_LAST_CAP CAP_SETFCAP
> 
> #define cap_valid(x) ((x) >= 0 && (x) <= CAP_LAST_CAP)
> 
> should also be ok for libcap.
> 
> > [...]
> > 
> > >  /*
> > >   * Bit location of each capability (used by user-space library and kernel)
> > >   */
> > > @@ -350,6 +354,17 @@ typedef struct kernel_cap_struct {
> > >  
> > >  #define CAP_INIT_INH_SET    CAP_EMPTY_SET
> > >  
> > 
> > Its kind of a pity to put a kernel config ifdef in a header file. Could
> > you put the ifdef code in the c-files that uses these definitions?
> 
> Hmm, now that you mention it, I notice that the exact same block of
> code is still in commoncap.c.  I must have lost the patch hunk dropping
> that some time ago...
> 
> But at this point CAP_INIT_BSET is only used in
> include/linux/init_task.h.  And I'd really rather not put the definition
> in there.
> 
> Note that the conditional is under a #ifdef __KERNEL__, so applications
> shouldn't be looking at it anyway.  Does that help?
> 
> > > +#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
> > 
> > In my experience when headers define things differently based on
> > configuration #defines, other users of header files (apps, kernel
> > modules etc.), never quite know what the current define is. If we can
> > avoid conditional code like this in this header file, I'd be happier.
> > 
> > > +#ifdef CONFIG_SECURITY_FILE_CAPABILITIES
> > 
> > ditto.
> 
> For this I really can't, because that is the recommended way to handle
> functions with different behavior per CONFIG_ variables.  #ifdefs are to
> be kept out of .c files to improve their readability, and helper
> functions called in .c files are to have their definition in .h files
> depend on the CONFIG_ variables.

On second thought, I'm going to do exactly what you suggest, because
removing CONFIG_SECURITY_FILE_CAPABILITIES checks severaly reduces
the amount of recompilation when you switch between
CONFIG_SECURITY_FILE_CAPABILITIES=y and n.

thanks,
-serge
