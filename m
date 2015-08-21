From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review 0/7] Bind mount escape fixes
Date: Fri, 21 Aug 2015 08:51:05 +0100
Message-ID: <20150821075105.GF18890@ZenIV.linux.org.uk>
References: <CA+55aFzMuCn33yK71HoKnj1hr8=ac_Y-vfE5mM8h4f3YJeGKvg@mail.gmail.com>
	<CA+55aFyeu-p_3eJQCLM0TDuLYvo10mx379FaCFq7Z103RgKvVA@mail.gmail.com>
	<E2AECA7F-ED57-4FCD-A4C0-8C7C4B860FB6@xmission.com>
	<CA+55aFx2s7TrmPKviKnFL0nGRZDHuCajW_UO02EnF+CsJY2-4w@mail.gmail.com>
	<20150816021209.GI14139@ZenIV.linux.org.uk>
	<CA+55aFy3pzEY=4dfd_PX-Og_b7fqrG1rDniOqehBfQhXb=Cg9A@mail.gmail.com>
	<20150816045322.GJ14139@ZenIV.linux.org.uk>
	<87fv3ju4zy.fsf@x220.int.ebiederm.org>
	<20150816065503.GL14139@ZenIV.linux.org.uk>
	<87bne7piwu.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87bne7piwu.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Sun, Aug 16, 2015 at 06:33:21AM -0500, Eric W. Biederman wrote:

> > ... or either of us can do merging those checks into a single place,
> > be it as a followup to your 7-patch series, or folded with the
> > fs/dcache.c-affecting patches in there.  If you have no time left, I can
> > certainly do that followup myself - not a problem[1]
> 
> I don't have time.  Everytime I have worked with this it has take pretty
> much full days of staring at the code, and I don't have any more full
> days left before the merge window.

OK, at that point I've pretty much given up on fs_pin for this cycle.
And testing your variant with unconditional checks on .. appears to have
fairly low overhead.  I still want to deal with catching and unmounting the
unreachable suckers, so fs/dcache.c side of things will get used when we get
to that stuff, but for now I've taken your 1/7, 2/7 plus the variant of
"vfs: Test for and handle paths that are unreachable from their mnt_root"
that doesn't care whether anything escaped or not.

3--6 are held in a local branch for now; I *am* going to use them
come next cycle.  And there's another pile of fun around that area, also
for the next cycle - kernel-initiated subtree removals on things like
sysfs et.al.; handling of the locking in those is inconsistent and tied
with the fun we have for d_move()/__d_unalias().  Sigh...
