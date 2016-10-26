From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 23:45:25 -0500
Message-ID: <87y41bvhui.fsf@xmission.com>
References: <1477414605.3079.40.camel@HansenPartnership.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<18846.1477416621@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <18846.1477416621-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org> (David Howells's
	message of "Tue, 25 Oct 2016 18:30:21 +0100")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
>
>> > There's another possibility here - since user_namespaces are 
>> > hierarchical, does it make sense to let a process see keys that are 
>> > in an ancestral namespace?
>> 
>> I think that should be the decision of the owner.  If you're creating a
>> userns to de-privilege the next user, likely you don't want this, but
>> if you're creating a userns to enhance it, then you do.
>
> Maybe the simplest is to put a 'stop here' flag on a user_namespace.  Then
> when we look to see if a key is in the caller's namespace, we go up the tree
> until we hit the flag.  If you don't find the key's ns within the caller's
> permitted subtree, you don't get to see the key.

Let me just say we already have all of that (in a much nicer format) by
limiting the set of keys we can access to the set of users visible in
the user namespace.

Eric
