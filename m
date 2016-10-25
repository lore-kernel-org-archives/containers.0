From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Tue, 25 Oct 2016 11:25:56 -0700
Message-ID: <1477419956.3079.66.camel__41526.6640521169$1477419997$gmane$org@HansenPartnership.com>
References: <1477414605.3079.40.camel@HansenPartnership.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<18846.1477416621@warthog.procyon.org.uk>
	<1477419204.3079.60.camel@HansenPartnership.com>
	<20161025182206.GD24481@laptop.thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20161025182206.GD24481-GiL72Q0nGm9Crx9znvW9yA@public.gmane.org>
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

On Tue, 2016-10-25 at 20:22 +0200, Jann Horn wrote:
> On Tue, Oct 25, 2016 at 11:13:24AM -0700, James Bottomley wrote:
> > On Tue, 2016-10-25 at 18:30 +0100, David Howells wrote:
> > > James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org> wrote:
> > > > I think you want to behave exactly as the mount namespace does:
> > > > on
> > > > initial clone, you get a fully cloned mount tree and then you 
> > > > customise it by unmounting pieces.
> > > 
> > > That adds quite a bit of complexity, given that:
> [...]
> > >  (2) there are quotas on the number of keys a user is permitted;
> > 
> > If this is counted per-id, then yes, mapping a range of ids with an
> > owning exterior non root user does allow you to escape the count 
> > ... how important is it?  Could we not simply hand wave it away as 
> > yet another consequence you have to think about when giving a user 
> > a range of exterior ids (because if there are N, their key count 
> > could get up to N * the limit).
> 
> Wouldn't it be N * normal_limit * number_of_namespaces, where
> number_of_namespaces is how many namespaces you can create (afaik
> unbounded)?

I need to understand why we have a limit first.  The above was assuming
it's something simple like an arbitrary limit to prevent resource
exhaustion.

but, assuming that again ... I was thinking enforce the limit by
exterior uid (kuid), so it becomes number of uids a user owns *
normal_limit.  It wouldn't vary based on the number of namespaces you
create.

James
