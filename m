From: Kunal Kushwaha <kunalkushwahaoss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Regarding lxc-0.8.0 on Centos 6.3
Date: Thu, 7 Feb 2013 10:24:54 +0530
Message-ID: <CAJXDyp6rPFkn3LuJoRJzp=CTGN-j_8dMK2ZpDpfzg2xy82nOpA@mail.gmail.com>
References: <CAJXDyp4+SM7xgwR+74HZROCbK=SQ8D2j-T-ii+ovYgSGis9WHw@mail.gmail.com>
	<20130206143043.GA4398@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130206143043.GA4398@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Thanks Serge,

It worked :).

For Note: To run ./configure for version 0.8.0 on CentOS
you should run command.

./configure --disable-apparmor

Best Regards,
Kunal Kushwaha




On Wed, Feb 6, 2013 at 8:00 PM, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>wrote:

> Quoting Kunal Kushwaha (kunalkushwahaoss-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > Hi,
> >
> > I am trying to install lxc-0.8.0 on CentOS 6.3. When I am trying to
> > ./configure it asks for apparmor.
>
> Do you have apparmor development libraries installed?  In any case,
> say "--disable-apparmor" to turn it off.
>
> (For the rest I don't know, but please look through the list archives,
> plenty of people have done it)
>
