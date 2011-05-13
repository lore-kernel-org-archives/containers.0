From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Testing Linux-CR -- Some Documentation
Date: Fri, 13 May 2011 09:51:40 -0500
Message-ID: <20110513145140.GA23848@mail.hallyn.com>
References: <BANLkTimjvdKGr_ZKpoozV5JzdbJeSE7PEA@mail.gmail.com>
	<20110513114245.GA4121@mail.hallyn.com> <4DCD3B3E.1040704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DCD3B3E.1040704-VXdhtT5mjnY@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Brian Haley (brian.haley-VXdhtT5mjnY@public.gmane.org):
> On 05/13/2011 07:42 AM, Serge E. Hallyn wrote:
> > Quoting Raghu D K (dk.raghu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >> However I was not able to run the test scripts ( runall.sh ) as it
> >> gave some errors. Also analyzing the "out" file using "ckptinfo"
> >> results in EOF error.
> >> Any additional help on this is appreciated.
> > 
> > Since you're on Ubuntu, sh points to dah, so many cr_tests will break
> > because they expect sh to point to bash.  You can fix that by going
> > through all the scripts and changing that.  I haven't had a chance to do
> > so yet, and definately won't today.  If you go through the effort,
> > please feel free to send a patch to Oren or myself.
> 
> Or you can run:
> 
> # sudo dpkg-reconfigure dash
> 
> and choose "No", which will make /bin/sh point to bash.

Good point :)

I should still fix the testcases when I have time, but this'll get
you running more easily :)
