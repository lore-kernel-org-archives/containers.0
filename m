From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 15:00:17 -0700
Message-ID: <1248300017.24021.344.camel__1367.5554459498$1248300176$gmane$org@nimitz>
References: <20090721220017.60A219D3@kernel>  <4A676ECC.1090400@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A676ECC.1090400-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-07-22 at 15:55 -0400, Mike Waychison wrote:
> > +#define FLEX_ARRAY_INIT(size, total) {{{\
> > +     .element_size = (size),         \
> > +     .nr_elements = 0,               \
> > +}}}
> > +
> 
> It's not clear how this guy is used.  It will initialize a flex_array, 
> but how is somebody expected to free the parts that get associated with it?

I tried to make that a bit more clear with the kerneldocs.
flex_array_free_parts() will free just the "parts" without touching the
"base" structure.  Otherwise, this macro is used in the same way as
RADIX_TREE_INIT().

> Is there a fancy way to make declaring a flex_array on stack a 
> compile-time error?

Not that I know of.  One thing that I did which makes this a _bit_
easier to detect is that sizeof(struct flex_array)==PAGE_SIZE instead of
just leaving a "void members[0]" at the end of the struct.  That means
that scripts/checkstack.pl should spot these.

I just double-checked:

$ objdump -d ../mhp-build/i386-qemu-smp/vmlinux | scripts/checkstack.pl i386
0xc02499d8 min_free_kbytes_sysctl_handler [vmlinux]:	4096
0xc0276619 do_sys_poll [vmlinux]:			896
0xc0276b49 do_select [vmlinux]:				704
...

That's after I added a 'struct flex_array f;' in
min_free_kbytes_sysctl_handler().

I'm happy to hear of anybody else's tricks, though.  I guess I could do
a WARN_ONCE() in some of the flex_array*() functions if we detect an
address that looks to be on the stack.  But, I can't think of any fancy
compile-time ones.

-- Dave
