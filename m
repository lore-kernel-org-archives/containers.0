From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Wed, 26 Oct 2016 15:34:50 +0100
Message-ID: <9243.1477492490@warthog.procyon.org.uk>
References: <CALCETrU0PqNYmWx70pugkhj-kAD5DSzSi3swhK+v12WMYZYUZA@mail.gmail.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
	<1477418708.3079.52.camel@HansenPartnership.com>
	<20161025181735.GC24481@laptop.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALCETrU0PqNYmWx70pugkhj-kAD5DSzSi3swhK+v12WMYZYUZA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-ID: <9242.1477492490.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:

> > | Not just questionable, completely wrong. The gist is that there is a
> > | *global* name -> key mapping for accessing keys by name, and user
> > | keyrings are stored in there under the name "_uid.%u", where %u
> > | refers to the *namespaced* UID. (See install_user_keyrings().)
> > | The result is that, if e.g. the user with UID 1000 has no running
> > | processes, a local attacker can enter a new user namespace, map UID
> > | 1000 in the namespace to some KUID he controls, do
> > | setresuid(1000, 1000, 1000), and now he owns user 1000's keyring.

Hmmm...  Having checked over the code, it might not be that simple.  Thanks to
something Eric Biederman added into find_keyring_by_name(), unless a keyring's
UID is a member of the current user namespace, you can't find that keyring by
name.

However, I'm not sure that that stops someone trying to find it by colliding
kuids since keys can't pin the user_struct without causing a loop.

Further, if the user_struct referring to a user (or user-session) keyring gets
deallocated, it drops its link to that keyring - though that's no guarantee
that the user keyrings will be deallocated themselves (there may be links from
elsewhere).

I'm wondering if I should move the user keyrings out of the user_struct so
that keys can pin the user_struct (and I could then merge the key_user struct
into it).

The user-keyring and user-session keyring could be kept in the user's
persistent keyring or in their own tree in the user namespace.  The former
would allow their easy reuse within a certain amount of time and the latter
would allow them to be easily revoked when the user_namespace struct is
destroyed.

I think Eric's patch to move the keyring list into the user_namespace struct
rather than having it be global is also a good step.

David
