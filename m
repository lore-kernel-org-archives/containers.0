From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] KEYS: allow changing key ownership with CAP_SYS_ADMIN in
	a NS
Date: Mon, 2 Oct 2017 23:11:21 -0500
Message-ID: <20171003041121.GA2751@mail.hallyn.com>
References: <20171003024528.28242-1-xnox@ubuntu.com>
	<87fub0gb6k.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87fub0gb6k.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Oct 02, 2017 at 10:30:43PM -0500, Eric W. Biederman wrote:
> Dimitri John Ledkov <xnox-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Currently, changing key ownership from one namespaced uid/gid to
> > another namespaced uid/gid is only allowed by processes that have
> > CAP_SYS_ADMIN in the intial namespace. Fix the capability check to
> > also check the capability in the current capability.
> 
> Nacked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> I won't deny the issue, but unless I am misreading something this
> will allow me to change the the uid of any key simply by unsharing
> a user namespace.  At which point there is no point in having a
> permission check at all.

Right so without having looked closely, at the very least you need to
verify that the ucrrent user is privileged over key->{uid,gid} and
over @user and @group.  Now the latter is I *think* being done
implicitly by the make_kuid(current_user_ns, user) at the top.  So
you need to further verify that key->uid and key->gid are mapped into
current_user_ns.

That *may* be sufficient.

-serge
