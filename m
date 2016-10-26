From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Wed, 26 Oct 2016 01:48:59 -0500
Message-ID: <877f8vtxk4.fsf@xmission.com>
References: <CALCETrU0PqNYmWx70pugkhj-kAD5DSzSi3swhK+v12WMYZYUZA@mail.gmail.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
	<1477418708.3079.52.camel@HansenPartnership.com>
	<20161025181735.GC24481@laptop.thejh.net>
	<20947.1477428095@warthog.procyon.org.uk>
	<87shrju031.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87shrju031.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Wed, 26 Oct 2016 00:54:26 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>
>> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>
>>> ... Perhaps we could simply *remove* the concept of named keys and keyrings.
>>
>> See Linus's dictum about breaking userspace.
>>
>> The problem isn't named keys: keys have to be named - the description is how
>> they're looked up typically.  Further, non-keyring keys can't be looked up
>> directly by name - you have to search for them in a keyring.
>>
>> The issue here is named keyrings and keyctl_join_session_keyring().  It might
>> well have been a bad idea - though I've seen some people arguing for a single
>> session keyring shared across all a user's logins, in which case, we might
>> want this after all (or use the user-default session).
>>
>> One thing we perhaps do want to do, though, is restrict the names of keyrings
>> to the user_namespace in which the keyring was created.
>
> Grr...
>
> The first round of user namespace support had actually restricted the
> description lookup to a single user namespace.  Then I missed a detail
> and converted the code to it's current form.  Ooops!
>
> I think the answer for all of the issues raised in this conversation is
> to just make the keyring names and the keyring name lookup per user
> namespace.
>
> Maybe a few small additional tweaks to install_user_keyrings to notice
> if we have the user keyring from the wrong user namespace.
>
> Something like the untested patch below.

Ugh but that approach runs into the fact that the uid_keyring lives
in user_struct.

So in the short term it is probably better to use the uid in the initial
user namespace in install_user_keyrings.  Then in
keyctl_join_session_keyring look for names that start with _uid. and
_uid_ses. and change the strings to have the numbers in the initial user
namespace instead of the current user namespace.

That would be the smallest change we could make, that would result
in correct code.

Eric
