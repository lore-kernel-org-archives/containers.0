From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Containers roadmap?
Date: Mon, 6 Apr 2009 17:36:24 -0500
Message-ID: <20090406223624.GA31708@us.ibm.com>
References: <20090406214127.GA1662@versecorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090406214127.GA1662-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Chris R. Jones" <chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Chris R. Jones (chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org):
> One more question for the experts:
> 
> Is there any roadmap out there for when we can see containers support in 
> kernels for the major distributions (RHEL or SLES in our case)?
> 
> When will the feature be enabled by default in the linux kernels?
> (containers options aren't enabled by default in 2.6.29.1, for instance).
> 
> We've done some prototyping to get our application working with containers and 
> really like the solution.  But so far we've had to build our own kernel and 
> and really need to use kernels that come with the distribution.  
> 
> Any rough estimates when that will be the case?

I'm not gonna speak for any distros, but I definately can say that
the Fedora 11 beta has all the kernel features enabled.  Network
namespaces, even devpts namespaces.

-serge
