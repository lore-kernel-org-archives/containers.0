From: Ramez Hanna <rhanna-jNDFPZUTrfTZNCtYfwcBIw@public.gmane.org>
Subject: Re: [Lxc-users] How to start the network services so as to get the IP
	address using lxc-execute???
Date: Thu, 8 Dec 2011 13:16:07 +0200
Message-ID: <CAFBTH1mzjbv3h6oM111acKo1D38XWCbS3fqCpKp+dMDBFWLKmg__27437.8644804985$1323343408$gmane$org@mail.gmail.com>
References: <CAHnfO6xppccpXCKQgNh32qiD69Qz4BTmjKM_dm9tk8hagKUsAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHnfO6xppccpXCKQgNh32qiD69Qz4BTmjKM_dm9tk8hagKUsAA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Dec 8, 2011 at 12:33 PM, nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi,
>
> I want to manually invoke a networking setup to start the network service to
> get the IP address of container , But the problem is i don't want to start
> the container and want to use lxc-execute.
>
> When I tried these things happened::
>
> command :: lxc-execute -n base -f /home/nishant/ubuntu.conf
> /var/lib/lxc/base1/rootfs/etc/init.d/networking start
>
> O/P
>
> Rather than invoking init scripts through /etc/init.d, use the service(8)
> utility, e.g. service networking start
>
> Since the script you are attempting to invoke has been converted to an
> Upstart job, you may also use the start(8) utility, e.g. start networking
> start: Unable to connect to Upstart: Failed to connect to socket
> /com/ubuntu/upstart: Connection refused
>
>
> How to start the network services so as to get the IP addresses of
> containers?
>
>
> Regards,
> Nishant
>
>
>
>
> ------------------------------------------------------------------------------
> Cloud Services Checklist: Pricing and Packaging Optimization
> This white paper is intended to serve as a reference, checklist and point of
> discussion for anyone considering optimizing the pricing and packaging model
> of a cloud services business. Read Now!
> http://www.accelacomm.com/jaw/sfnl/114/51491232/
> _______________________________________________
> Lxc-users mailing list
> Lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> https://lists.sourceforge.net/lists/listinfo/lxc-users
>

looks like the upstart scripts need upstart to be running!
you could use a different script to start the networking say from a sysv init
but I am not sure that with execute you will get the networking
stack/isolation  available

-- 
BR
RH
http://informatiq.org
