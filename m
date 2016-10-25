From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 11:21:44 -0700
Message-ID: <1477419704.3079.63.camel@HansenPartnership.com>
References: <17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
	<1477418708.3079.52.camel@HansenPartnership.com>
	<20161025181735.GC24481@laptop.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161025181735.GC24481-GiL72Q0nGm9Crx9znvW9yA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2016-10-25 at 20:17 +0200, Jann Horn wrote:
> On Tue, Oct 25, 2016 at 11:05:08AM -0700, James Bottomley wrote:
> > On Tue, 2016-10-25 at 19:06 +0200, Jann Horn wrote:
> > > On Tue, Oct 25, 2016 at 09:56:45AM -0700, James Bottomley wrote:
> > > > On Tue, 2016-10-25 at 17:53 +0100, David Howells wrote:
> > > > > David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > > 
> > > > > >  (2) If a process's user_namespace doesn't match that
> > > > > > recorded
> > > > > > in a
> > > > > > key then
> > > > > >      it gets ENOKEY if it tries to refer to it or access it
> > > > > > and
> > > > > > can't see it
> > > > > >      in /proc/keys.
> > > > > 
> > > > > There's another possibility here - since user_namespaces are 
> > > > > hierarchical, does it make sense to let a process see keys
> > > > > that
> > > > > are 
> > > > > in an ancestral namespace?
> > > > 
> > > > I think that should be the decision of the owner.  If you're
> > > > creating a
> > > > userns to de-privilege the next user, likely you don't want
> > > > this,
> > > > but
> > > > if you're creating a userns to enhance it, then you do.
> > > > 
> > > > I think you want to behave exactly as the mount namespace does:
> > > > on
> > > > initial clone, you get a fully cloned mount tree and then you
> > > > customise
> > > > it by unmounting pieces.
> > > 
> > > The issue with keys is that their interface is pretty broken when
> > > exposed to user namespaces with different UID mappings, and this
> > > also 
> > > causes security issues where you can get access to other users' 
> > > keyrings and stuff like that. The proposed fix works around that 
> > > brokenness by simply never exposing keys to other namespaces.
> > 
> > Define how ... we can fix the keyring interface if it's hugely
> > problematic.
> 
> See http://lkml.iu.edu/hypermail/linux/kernel/1606.2/06794.html .
> Here's a copy of my explanation in that message:
> 
> > Not just questionable, completely wrong. The gist is that there is
> > a
> > *global* name -> key mapping for accessing keys by name, and user
> > keyrings are stored in there under the name "_uid.%u", where %u
> > refers to the *namespaced* UID. (See install_user_keyrings().)
> > The result is that, if e.g. the user with UID 1000 has no running
> > processes, a local attacker can enter a new user namespace, map UID
> > 1000 in the namespace to some KUID he controls, do
> > setresuid(1000, 1000, 1000), and now he owns user 1000's keyring.
> > This ends up permitting the attacker to dump the contents of KUID
> > 1000's keys after KUID 1000 signs in. I discovered this while going
> > through the kuid->uid conversions when I thought about writing this
> > feature the first time.

Well, that's obviously wrong and we fix it before adding namespaced
views of keyrings.  Originally I would say it needs to be kuid, like
filesystems, but now Eric is on with an additional namespace mapping at
the filesystem boundary, I'll defer to him whether he thinks we should
have something like it at the key naming one as well.

This is starting to sound like a useful late arriving discussion topic
for the Plumbers Containers MC ...

James
