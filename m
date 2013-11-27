From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: userns idea: preventing SCM_CREDENTIALS from leaking out
Date: Wed, 27 Nov 2013 12:47:13 -0600
Message-ID: <20131127184713.GB10914@sergelap>
References: <CALCETrWWSVnwg6Sb=bZz0xuAj_ASjZmsLYy=ELoR_uSqKJJaWg@mail.gmail.com>
	<20131127014920.GA31364@mail.hallyn.com>
	<87eh62v8hc.fsf@xmission.com>
	<20131127144431.GA6122@mail.hallyn.com>
	<CALCETrVXKHO4=Q+0szERmte+5HYJMwVXnXJxLTdBThmoQMMPcg@mail.gmail.com>
	<CAJfpeguHPFcX07bM=+3JJrV1kanDxp5wZWj4jBo-+1EMceonqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAJfpeguHPFcX07bM=+3JJrV1kanDxp5wZWj4jBo-+1EMceonqg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Miklos Szeredi (miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org):
> On Wed, Nov 27, 2013 at 5:24 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> >> Actually an option to aufs and overlayfs to say "any unix domain socket
> >> which is opened must first be copied to the writeable layer" would
> >> solve the issue (at least for all reasonable cases, iiuc)
> >
> > I guess I'm reasonably convinced that overlayfs is the right place to
> > fix this.  (Containers using lvm will be left in the cold -- oh,
> > well.)
> >
> > cc: Miklos, who is the most likely to implement one or both of these features.
> 
> AFAICS implementing the option to copy up a unix domain socket on open
> is trivial:  just need to tweak ovl_open_need_copy_up().
> 
> Is that what you were thinking?

Exactly.

thanks,
-serge
