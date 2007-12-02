From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 1 Dec 2007 16:30:35 -0800
Message-ID: <20071201163035.321fd554@freepuppy.rosehill>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071201111736.297dd99a@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
To: netdev@vger.kernel.org
Cc: containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Sat, 1 Dec 2007 11:17:36 -0800
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> Then init_net needs to be not GPL limited. Sorry, we need to allow
> non GPL network drivers.  There is a fine line between keeping the
> binary seething masses from accessing random kernel functions, and allowing
> reasonable (but still non GPL) things like ndiswrapper to use network
> device interface.
> 
I spoke too soon earlier, ndiswrapper builds and loads against current
2.6.24-rc3. Vmware and proprietary VPN software probably do not. Once again I don't
give a damn, but the enterprise distro vendors certainly care.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

