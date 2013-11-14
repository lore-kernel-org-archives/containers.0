From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Getting userns enabled in vendor kernels
Date: Thu, 14 Nov 2013 17:48:32 +0000
Message-ID: <20131114174832.GA14809@mail.hallyn.com>
References: <20131113151330.GZ32643@redhat.com>
	<1384444373.2005.8.camel@dabdike.int.hansenpartnership.com>
	<20131114174401.GF12097@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131114174401.GF12097-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Aristeu Rozanski (aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> (Replying also to Serge, same argument)
> On Thu, Nov 14, 2013 at 07:52:53AM -0800, James Bottomley wrote:
> > The thing that worries me is that turning this off means no-one will
> > work on the bugs and one day distros will start to use USER_NS for
> > things other than containers.  When that happens, container roots will
> > need to use it to bring up distro IaaS instances.
> 
> True, but the status we have now is that USER_NS is disabled completely
> in Fedora. This approach will split the process in two: enable part of
> it, let it soak, solve problems, enable user created namespaces later.

Right - so my suggestion is that we agree on a 100% identical patch for anyone
who must use such a patch to justify enabling USER_NS to use.  But that we not
push it upstream.  (Ubuntu would hopefully not use it - unless the overmount bug
does not get fixed in a timely manner.)

-serge
