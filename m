From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/7] user namespaces: convert all capable checks in
	kernel/sys.c
Date: Tue, 11 Jan 2011 05:27:59 +0000
Message-ID: <20110111052759.GA24970__47071.9734709293$1294723865$gmane$org@mail.hallyn.com>
References: <20110110211135.GA22446@mail.hallyn.com>
	<20110110211406.GF22564@mail.hallyn.com>
	<20110110215937.GB21351@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110110215937.GB21351-0IJIQSrh9RL9UF0aPl6fsj8Kkb2uy4ct@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM
List-Id: containers.vger.kernel.org

Quoting Bastian Blank (bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org):
> On Mon, Jan 10, 2011 at 09:14:07PM +0000, Serge E. Hallyn wrote:
> > -	if (pcred->uid  != cred->euid &&
> > -	    pcred->euid != cred->euid && !capable(CAP_SYS_NICE)) {
> > +	if (pcred->user->user_ns != cred->user->user_ns &&
> > +	    pcred->uid  != cred->euid &&
> > +	    pcred->euid != cred->euid &&
> > +	    !ns_capable(pcred->user->user_ns, CAP_SYS_NICE)) {
> 
> I don't think this is correct. This would not error out if the both
> userns are the same. Because the same patern (check uid if same userns,
> otherwise only capability) shows up in several parts of the code, maybe
> this should be factored out.

Yeah, I'd really like to factor this out because it shows up everywhere
and I have to think about it every time I look at it.  But each time it
shows up, the uids being compared slightly change.  There must be some
clever way of doing it, hopefully it'll fall out soon.

Eric's ns_capable() has already simplified this quite a bit - which is
part of why I've sometimes not been thinking about it right, it's now
simpler than it used to be :)

thanks,
-serge
