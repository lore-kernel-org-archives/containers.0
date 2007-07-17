From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: Containers: css_put() dilemma
Date: Tue, 17 Jul 2007 10:58:40 -0700
Message-ID: <20070717105840.1e25c7ce.pj@sgi.com>
References: <469BBE00.8000709@linux.vnet.ibm.com>
	<6599ad830707161203o7f148c75p52e77d4be3ace487@mail.gmail.com>
	<469C2792.6050009@linux.vnet.ibm.com>
	<6599ad830707161935n69776f1t98292fc9990f4766@mail.gmail.com>
	<20070717070031.GA22410@linux.vnet.ibm.com>
	<6599ad830707170018p180cb7dfr53e609fd0b186e30@mail.gmail.com>
	<469C99D1.7090807@linux.vnet.ibm.com>
	<6599ad830707170849v11fe8cecs6d172cd38d247e09@mail.gmail.com>
	<469CFF2B.1080702@linux.vnet.ibm.com>
	<20070717105341.9e51cc79.pj@sgi.com>
	<6599ad830707171055ua1e1135ief95a5ff3cf9dfc9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830707171055ua1e1135ief95a5ff3cf9dfc9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Paul (=?ISO-8859-1?Q?=5F=5F=5F=5F=5F=5F?=) Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-3ImXcnM4P+0@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Paul M wrote:
> Right, that's what the release agent patch for process containers does
> - there's a file in the hierarchy root called "release_agent" that
> contains the path to the program to run if a notify_on_release
> container goes idle. When you mount the "cpuset" filesystem, it
> automatically populates that file with "/sbin/cpuset_release_agent".

Cool -- thanks.  Sounds good.

Nevermind my other "what's the Subject" query, if you haven't
already answered it.  You just nicely answered my questions.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.925.600.0401
