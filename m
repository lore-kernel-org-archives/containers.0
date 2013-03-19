From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] fs: allow dev accesses in userns in controlled
	situations
Date: Tue, 19 Mar 2013 14:15:18 -0500
Message-ID: <20130319191518.GA25414@sergelap>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<1363338823-25292-3-git-send-email-glommer@parallels.com>
	<20130315142045.GD3782@sergelap>
	<CAE=Ncradvs_twWT8b6NQz85dm-Y8ayTH7NFv=i0vjYXpRBW9sg@mail.gmail.com>
	<20130319153740.GA21908@sergelap>
	<CAE=NcrYeKQYqkPsB9FG5PpYd2VTqmTszfpY39aRJqR=vsXfa7w@mail.gmail.com>
	<20130319172759.GB7027@sergelap>
	<CAE=NcraBvk_hwCd9BgASpDBkmEB+fg-kKwAPbT7bQeFRbq5DSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAE=NcraBvk_hwCd9BgASpDBkmEB+fg-kKwAPbT7bQeFRbq5DSg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Janne Karhunen (janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Tue, Mar 19, 2013 at 7:27 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> >> Classic on/off toggle case is easy though, but are there enough
> >> reasons for merging such 'noop' namespace?
> >
> > Eric's point is precisely that we may be able to work aruond it
> > sufficiently that we don't need to.  Noone has proposed a specific
> > design let alone code, so it's premature to talk about merging
> > anything :)
> 
> Well let's see that after I get this booting :P

Oh - you have code?  Fun :)

-serge
